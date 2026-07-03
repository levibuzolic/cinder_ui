defmodule CinderUI.PackageArtifactTest do
  @moduledoc """
  Guards the Hex package artifact so the files required for the default
  (non-copy) install mode are actually shipped.

  In the default mode `mix cinder_ui.install` patches a consumer's `app.js`/
  `app.css` to reference Cinder UI from `deps/cinder_ui`. If `package.json` or
  the JS/CSS templates ever drop out of the `mix.exs` `:files` list, those
  imports break silently in consuming projects. This builds the real Hex tarball
  and asserts the entrypoints are present.
  """
  use ExUnit.Case, async: false

  @required ~w(
    package.json
    priv/templates/cinder_ui.css
    priv/templates/cinder_ui/index.js
  )

  test "hex package tarball ships the assets consumed from deps/cinder_ui" do
    tmp = Path.join(System.tmp_dir!(), "cinder-ui-pkg-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)

    tar_path = Path.join(tmp, "package.tar")

    {output, status} =
      System.cmd("mix", ["hex.build", "--output", tar_path], stderr_to_stdout: true)

    assert status == 0, output

    names = package_file_names(tar_path)

    for path <- @required do
      assert path in names,
             "expected #{path} in the Hex package, got:\n#{Enum.join(names, "\n")}"
    end
  end

  defp package_file_names(tar_path) do
    {:ok, outer} = :erl_tar.extract({:binary, File.read!(tar_path)}, [:memory])
    {_, contents_gz} = Enum.find(outer, fn {name, _} -> to_string(name) == "contents.tar.gz" end)
    {:ok, inner} = :erl_tar.extract({:binary, contents_gz}, [:memory, :compressed])
    Enum.map(inner, fn {name, _} -> to_string(name) end)
  end
end
