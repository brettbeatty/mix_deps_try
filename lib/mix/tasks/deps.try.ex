defmodule Mix.Tasks.Deps.Try do
  use Mix.Task

  @impl Mix.Task
  def run(args)

  def run([app, version]) do
    app = String.to_atom(app)

    build_tmp_project!(app, version)

    Application.ensure_all_started(app)
  end

  def run([app]) do
    run([app, ">=0.0.0"])
  end

  def run(_args) do
    Mix.raise("Usage: mix deps.try <app> [version]")
  end

  @spec build_tmp_project!(app :: atom(), version :: binary()) :: none()
  defp build_tmp_project!(app, version) do
    Mix.ProjectStack.clear_stack()

    app
    |> write_tmp_project!(version)
    |> compile_project!()

    Mix.Task.run("deps.get")
    Mix.Task.run("deps.compile")
  end

  @spec write_tmp_project!(app :: atom(), version :: binary()) :: Path.t()
  defp write_tmp_project!(app, version) do
    tag = generate_tag()

    dir = Path.join([System.tmp_dir!(), "mix_deps_try", to_string(tag)])
    File.mkdir_p!(dir)

    file = Path.join(dir, "mix.exs")
    File.write!(file, generate_mix_exs(tag, app, version, dir))

    file
  end

  @spec generate_tag() :: atom()
  defp generate_tag do
    6
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> String.to_atom()
  end

  @spec generate_mix_exs(tag :: atom, app :: atom(), version :: binary(), dir :: Path.t()) ::
          iodata()
  defp generate_mix_exs(tag, app, version, dir) do
    config = [
      app: tag,
      version: "0.0.0",
      deps: [{app, version}],
      build_path: Path.join(dir, "_build"),
      config_path: Path.join(dir, "config/config.exs"),
      deps_path: Path.join(dir, "deps"),
      lockfile: Path.join(dir, "mix.lock")
    ]

    """
    defmodule #{inspect(tag)} do
      use Mix.Project

      def project do
        #{inspect(config)}
      end
    end
    """
  end

  @spec compile_project!(file :: Path.t()) :: none()
  if function_exported?(Code, :compile_file, 1) do
    defp compile_project!(file) do
      Code.compile_file(file)
    end
  else
    defp compile_project!(file) do
      Code.load_file(file)
    end
  end
end
