defmodule Demo.CinderUIResolutionTest do
  @moduledoc """
  End-to-end resolution smoke test for the default (non-copy) install mode.

  The library's own unit tests assert *what* `mix cinder_ui.install` writes into
  `app.js`/`app.css`. They cannot prove the patched output actually resolves,
  because that depends on external toolchain behavior — esbuild resolving the
  `cinder_ui` package via `NODE_PATH`, and Tailwind resolving the CSS
  `@import`/`@plugin` by walking up to the project-root `node_modules`.

  This builds a throwaway, consumer-shaped fixture that references Cinder UI from
  `deps/cinder_ui` and runs the real esbuild and Tailwind binaries against it.
  """
  use ExUnit.Case, async: false

  @repo_root Path.expand("../..", __DIR__)
  @demo_root Path.expand("..", __DIR__)

  setup_all do
    # The demo installs these during `mix assets.setup`; ensure they exist so the
    # test can run as part of the normal suite.
    Mix.Task.run("esbuild.install", ["--if-missing"])
    Mix.Task.run("tailwind.install", ["--if-missing"])
    :ok
  end

  setup do
    tmp =
      Path.join(
        System.tmp_dir!(),
        "cinder-ui-resolution-#{System.unique_integer([:positive])}"
      )

    on_exit(fn -> File.rm_rf!(tmp) end)

    # A physical copy of `deps/cinder_ui`, so Tailwind's upward `node_modules`
    # lookup for `@plugin` resolves against the fixture root the way it would in
    # a real consumer (a symlink would resolve to the source repo instead).
    deps_pkg = Path.join([tmp, "deps", "cinder_ui"])
    File.mkdir_p!(Path.join(deps_pkg, "priv/templates"))
    File.cp!(Path.join(@repo_root, "package.json"), Path.join(deps_pkg, "package.json"))

    File.cp_r!(
      Path.join(@repo_root, "priv/templates/cinder_ui"),
      Path.join(deps_pkg, "priv/templates/cinder_ui")
    )

    File.cp!(
      Path.join(@repo_root, "priv/templates/cinder_ui.css"),
      Path.join(deps_pkg, "priv/templates/cinder_ui.css")
    )

    # `tailwindcss-animate` must resolve from the project-root node_modules.
    File.ln_s!(Path.join(@demo_root, "node_modules"), Path.join(tmp, "node_modules"))

    css_dir = Path.join([tmp, "assets", "css"])
    js_dir = Path.join([tmp, "assets", "js"])
    File.mkdir_p!(css_dir)
    File.mkdir_p!(js_dir)

    File.write!(Path.join(css_dir, "app.css"), """
    @import "tailwindcss" source(none);
    @source "../../deps/cinder_ui";
    @import "../../deps/cinder_ui/priv/templates/cinder_ui.css";
    """)

    File.write!(Path.join(js_dir, "app.js"), """
    import { CinderUIHooks, CinderUI } from "cinder_ui"
    console.log(Object.keys(CinderUIHooks), typeof CinderUI.dispatchCommand)
    """)

    %{tmp: tmp}
  end

  test "esbuild resolves the cinder_ui package import from deps", %{tmp: tmp} do
    out = Path.join(tmp, "out.js")

    {output, status} =
      System.cmd(
        Esbuild.bin_path(),
        [
          Path.join([tmp, "assets", "js", "app.js"]),
          "--bundle",
          "--target=es2022",
          "--outfile=#{out}"
        ],
        env: [{"NODE_PATH", Path.join(tmp, "deps")}],
        stderr_to_stdout: true
      )

    assert status == 0, output

    bundle = File.read!(out)
    assert bundle =~ "CuiDialog"
    assert bundle =~ "CuiCombobox"
    assert bundle =~ "dispatchCommand"
  end

  test "tailwind resolves the css @import and @plugin from deps", %{tmp: tmp} do
    out = Path.join(tmp, "out.css")

    {output, status} =
      System.cmd(
        Tailwind.bin_path(),
        ["--input=assets/css/app.css", "--output=#{out}"],
        cd: tmp,
        stderr_to_stdout: true
      )

    assert status == 0, output

    css = File.read!(out)
    # Theme tokens sourced from cinder_ui.css.
    assert css =~ "oklch("
    # Output contributed by the tailwindcss-animate `@plugin`.
    assert css =~ ~r/fade-(in|out)|animate-(in|out)/
  end
end
