defmodule CinderUI.PackageArtifactTest do
  @moduledoc """
  Guards the Hex package artifact so the files required for the default
  (non-copy) install mode are actually shipped.

  In the default mode `mix cinder_ui.install` patches a consumer's `app.js`/
  `app.css` to reference Cinder UI from `deps/cinder_ui`. If `package.json` or
  the JS/CSS templates ever drop out of the `mix.exs` `:files` list, those
  imports break silently in consuming projects.

  This expands the declared `:files` globs the same way Hex does when building
  the tarball and asserts the entrypoints are included. We expand in-process
  rather than shelling out to `mix hex.build` so the check does not depend on
  the whole package validating in every CI job (e.g. generated `doc/screenshots`
  are absent in the unit-test job).
  """
  use ExUnit.Case, async: true

  @required ~w(
    package.json
    priv/templates/cinder_ui.css
    priv/templates/cinder_ui/index.js
  )

  test "hex package files include the assets consumed from deps/cinder_ui" do
    shipped = shipped_files()

    for path <- @required do
      assert path in shipped,
             "expected #{path} to ship in the Hex package (mix.exs :files)"
    end
  end

  defp shipped_files do
    Mix.Project.config()
    |> Keyword.fetch!(:package)
    |> Keyword.fetch!(:files)
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.flat_map(fn path ->
      if File.dir?(path), do: Path.wildcard(Path.join(path, "**")), else: [path]
    end)
    |> Enum.filter(&File.regular?/1)
    |> MapSet.new()
  end
end
