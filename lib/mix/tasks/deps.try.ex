defmodule Mix.Tasks.Deps.Try do
  use Mix.Task

  @impl Mix.Task
  def run(args)

  def run([app, version]) do
    Mix.ProjectStack.clear_stack()
    {_project, file} = generate_new_project!(app, version)
    configure_relative(file)
    compile_file(file)
    Mix.Task.run("deps.get")
    Mix.Task.run("deps.compile")
    Application.ensure_all_started(String.to_atom(app))
  end

  if function_exported?(Code, :compile_file, 1) do
    defdelegate compile_file(file), to: Code
  else
    defdelegate compile_file(file), to: Code, as: :load_file
  end

  def run([app]) do
    run([app, ">=0.0.0"])
  end

  def run(_args) do
    Mix.raise("Usage: mix deps.try <app> [version]")
  end

  @spec generate_new_project!(app :: binary(), version :: binary()) :: {atom(), Path.t()}
  defp generate_new_project!(app, version) do
    project = generate_tag()
    dir = Path.join("/tmp/mix_deps_try", to_string(project))
    File.mkdir_p!(dir)
    file = Path.join(dir, "mix.exs")
    File.write(file, generate_mix_exs(project, app, version))
    {project, file}
  end

  @spec generate_tag() :: atom()
  defp generate_tag do
    6
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> String.to_atom()
  end

  @spec generate_mix_exs(project :: atom(), app :: binary(), version :: binary()) :: iodata()
  defp generate_mix_exs(project, app, version) do
    project = inspect(project)
    app = app |> String.to_atom() |> inspect()
    version = inspect(version)

    """
    defmodule #{project} do
      use Mix.Project

      def project do
        [
          app: #{project},
          version: "0.0.0",
          deps: [
            {#{app}, #{version}}
          ]
        ]
      end
    end
    """
  end

  @spec configure_relative(file :: Path.t()) :: none()
  defp configure_relative(file) do
    dir = Path.dirname(file)

    Mix.ProjectStack.post_config(
      build_path: Path.join(dir, "_build"),
      config_path: Path.join(dir, "config/config.exs"),
      deps_path: Path.join(dir, "deps"),
      lockfile: Path.join(dir, "mix.lock")
    )
  end
end
