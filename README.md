# mix deps.try

I often find myself creating empty Elixir projects to play with dependencies in IEx. This mix task
is intended to simplify that process. If you know of a better way to do it, please let me know.

## Installation

I don't want to publish this to hex unless/until it gets a little more polished, has tests, etc.
You can still install it directly from GitHub.

```
$ mix archive.install github brettbeatty/mix_deps_try
```

## Usage

I intended for this to be run with IEx. For right now it takes an app name and optional version
string, creates a dummy project in the `/tmp` directory, and installs the given app.

```
$ iex -S mix deps.try ecto '~> 3.4.5'
Erlang/OTP 23 [erts-11.0.2] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Resolving Hex dependencies...
Dependency resolution completed:
New:
  decimal 2.0.0
  ecto 3.4.6
  telemetry 0.4.2
* Getting ecto (Hex package)
* Getting decimal (Hex package)
* Getting telemetry (Hex package)
===> Compiling telemetry
==> decimal
Compiling 4 files (.ex)
Generated decimal app
==> ecto
Compiling 55 files (.ex)
warning: Decimal.cmp/2 is deprecated. Use compare/2 instead
  lib/ecto/changeset.ex:2149: Ecto.Changeset.validate_number/6

Generated ecto app
Interactive Elixir (1.10.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Ecto.UUID.generate()
"71a73f83-8774-4592-9bca-438824996b35"
```
