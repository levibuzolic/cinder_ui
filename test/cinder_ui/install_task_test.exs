defmodule CinderUI.InstallTaskTest do
  use ExUnit.Case, async: false

  @task "cinder_ui.install"

  setup do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "cinder-ui-install-test-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(tmp_dir)

    on_exit(fn ->
      File.rm_rf!(tmp_dir)
    end)

    %{tmp_dir: tmp_dir}
  end

  test "references deps without copying files or installing packages", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    run_install(project, ["--assets-path", "assets"])

    refute File.exists?(Path.join(assets, "css/cinder_ui.css"))
    refute File.exists?(Path.join(assets, "js/cinder_ui.js"))
    refute File.exists?(Path.join(assets, "package.json"))

    app_css = File.read!(Path.join(assets, "css/app.css"))
    assert app_css =~ "@source \"../../deps/cinder_ui\";"
    assert app_css =~ "@import \"../../deps/cinder_ui/priv/templates/cinder_ui.css\";"

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "import { CinderUIHooks } from \"cinder_ui\""
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "merges Cinder UI hooks into colocated hooks live socket config", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      import {hooks as colocatedHooks} from \"phoenix-colocated/demo_app\"
      const liveSocket = new LiveSocket(\"/live\", Socket, {
        hooks: {...colocatedHooks},
      })
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "import { CinderUIHooks } from \"cinder_ui\""
    assert app_js =~ "hooks: {...colocatedHooks, ...CinderUIHooks}"
  end

  test "merges Cinder UI hooks when the live socket hooks key is quoted", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      const liveSocket = new LiveSocket("/live", Socket, {
        "hooks": {DemoHook},
      })
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))

    assert app_js =~ ~s("hooks": {DemoHook, ...CinderUIHooks})
    refute app_js =~ "window.Hooks"
  end

  test "merges Cinder UI hooks into inline live socket hooks config", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      import DemoHook from "./demo_hook"
      const liveSocket = new LiveSocket("/live", Socket, {
        hooks: {
          DemoHook,
        },
      })
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "import { CinderUIHooks } from \"cinder_ui\""
    assert app_js =~ "DemoHook"
    assert app_js =~ "...CinderUIHooks"
  end

  test "merges Cinder UI hooks into nested inline hook objects", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      const ignored = "hooks: {}"
      const liveSocket = new LiveSocket("/live", Socket, {
        hooks: {
          DemoHook: {
            mounted() {
              this.payload = {nested: true}
            },
          },
        },
      })
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "this.payload = {nested: true}"
    assert app_js =~ ~r/hooks:\s*\{.*DemoHook: \{.*\},\n\s+\.\.\.CinderUIHooks\n\s+\}/s
  end

  test "merges inline hooks without treating regex delimiters as JavaScript structure", %{
    tmp_dir: tmp_dir
  } do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      const liveSocket = new LiveSocket("/live", Socket, {
        hooks: {
          DemoHook: {
            mounted() {
              this.delimiterPattern = /[})]/
            },
          },
        },
      })
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))

    assert app_js =~ "this.delimiterPattern = /[})]/"
    assert app_js =~ ~r/hooks:\s*\{.*DemoHook: \{.*\},\n\s+\.\.\.CinderUIHooks\n\s+\}/s
  end

  test "skip-patching preserves app files", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    original_app_css = "@import \"tailwindcss\";\n/* keep */\n"
    original_app_js = "import {LiveSocket} from \"phoenix_live_view\"\nlet Hooks = {}\n"
    File.write!(Path.join(assets, "css/app.css"), original_app_css)
    File.write!(Path.join(assets, "js/app.js"), original_app_js)

    run_install(project, ["--assets-path", "assets", "--skip-patching"])

    assert File.read!(Path.join(assets, "css/app.css")) == original_app_css
    assert File.read!(Path.join(assets, "js/app.js")) == original_app_js
  end

  test "dry-run reports changes without writing files", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    original_app_css = "@import \"tailwindcss\";\n"
    original_app_js = "import {LiveSocket} from \"phoenix_live_view\"\nlet Hooks = {}\n"
    File.write!(Path.join(assets, "css/app.css"), original_app_css)
    File.write!(Path.join(assets, "js/app.js"), original_app_js)

    Mix.shell(Mix.Shell.Process)

    try do
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--dry-run"])
      end)

      assert_received {:mix_shell, :info, ["would update assets/css/app.css"]}
      assert_received {:mix_shell, :info, ["would update assets/js/app.js"]}
      assert_received {:mix_shell, :info, ["Cinder UI dry run complete."]}
    after
      Mix.shell(Mix.Shell.IO)
    end

    assert File.read!(Path.join(assets, "css/app.css")) == original_app_css
    assert File.read!(Path.join(assets, "js/app.js")) == original_app_js
  end

  test "help flag prints task docs", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    File.mkdir_p!(project)

    File.cd!(project, fn ->
      Mix.Task.reenable(@task)
      Mix.shell(Mix.Shell.Process)

      try do
        Mix.Task.run(@task, ["--help"])
        assert_received {:mix_shell, :info, [text]}
        assert text =~ "Installs Cinder UI into a Phoenix project."
      after
        Mix.shell(Mix.Shell.IO)
      end
    end)
  end

  test "raises when the assets path does not exist", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    File.mkdir_p!(project)

    assert_raise Mix.Error, ~r/assets path not found/, fn ->
      run_install(project, ["--assets-path", "missing"])
    end
  end

  test "rejects unknown options before writing to the default assets path", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    app_css = Path.join(assets, "css/app.css")
    app_js = Path.join(assets, "js/app.js")

    File.mkdir_p!(Path.dirname(app_css))
    File.mkdir_p!(Path.dirname(app_js))
    File.write!(app_css, "@import \"tailwindcss\";\n")
    File.write!(app_js, "let Hooks = {}\n")

    assert_raise Mix.Error, ~r/unknown option.*--asset-path/, fn ->
      run_install(project, ["--asset-path", "elsewhere"])
    end

    assert File.read!(app_css) == "@import \"tailwindcss\";\n"
    assert File.read!(app_js) == "let Hooks = {}\n"
  end

  test "falls back to a global hooks merge when no hooks binding is found", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "const socket = {}\n")

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
    assert app_js =~ "window.Hooks = Hooks"
  end

  test "lowercase hooks and pre-merged hooks are preserved correctly", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(Path.join(assets, "js/app.js"), "let hooks = {}\n")

    run_install(project, ["--assets-path", "assets"])
    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "Object.assign(hooks, CinderUIHooks)"
    assert length(:binary.matches(app_js, "Object.assign(hooks, CinderUIHooks)")) == 1

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      import { CinderUIHooks } from "cinder_ui"
      const liveSocket = new LiveSocket("/live", Socket, {
        hooks: {...colocatedHooks, ...CinderUIHooks},
      })
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert String.split(app_js, "...CinderUIHooks") |> length() == 2
  end

  test "commented hook integration does not count as installed", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      // import { CinderUIHooks } from "cinder_ui"
      // hooks: {...CinderUIHooks}
      let Hooks = {}
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))

    assert app_js =~ ~r/^import \{ CinderUIHooks \} from "cinder_ui"$/m

    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "commented empty hook bindings are not rewritten as executable code", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "// let Hooks = {}\nconst socket = {}\n")

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))

    assert app_js =~ "// let Hooks = {}\nconst socket = {}"
    assert app_js =~ "let Hooks = window.Hooks || {}"
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "hook integration shown in a template string does not count as installed", %{
    tmp_dir: tmp_dir
  } do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      const instructions = `
      import { CinderUIHooks } from "cinder_ui"
      hooks: {...CinderUIHooks}
      `
      let Hooks = {}
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))

    assert length(Regex.scan(~r/^import \{ CinderUIHooks \} from "cinder_ui"$/m, app_js)) == 2
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "unrelated hooks objects are not mutated", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      const analytics = {hooks: {beforeSend}}
      let Hooks = {}
      const liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
      """
    )

    run_install(project, ["--assets-path", "assets"])

    app_js = File.read!(Path.join(assets, "js/app.js"))

    assert app_js =~ "const analytics = {hooks: {beforeSend}}"
    refute app_js =~ "const analytics = {hooks: {beforeSend, ...CinderUIHooks}}"
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "CSS directives shown in comments do not count as installed", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))

    File.write!(
      Path.join(assets, "css/app.css"),
      """
      @import "tailwindcss";
      /*
      @source "../../deps/cinder_ui";
      @import "../../deps/cinder_ui/priv/templates/cinder_ui.css";
      */
      """
    )

    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    run_install(project, ["--assets-path", "assets"])

    app_css = File.read!(Path.join(assets, "css/app.css"))

    assert length(Regex.scan(~r/^@source "\.\.\/\.\.\/deps\/cinder_ui";$/m, app_css)) == 2

    assert length(
             Regex.scan(
               ~r/^@import "\.\.\/\.\.\/deps\/cinder_ui\/priv\/templates\/cinder_ui\.css";$/m,
               app_css
             )
           ) == 2
  end

  defp run_install(project, args) do
    File.cd!(project, fn ->
      Mix.Task.reenable(@task)
      Mix.Task.run(@task, args)
    end)
  end
end
