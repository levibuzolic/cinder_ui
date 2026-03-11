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

  test "installs into project root package manager when root package.json exists", %{
    tmp_dir: tmp_dir
  } do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    assert File.exists?(Path.join(assets, "css/cinder_ui.css"))
    assert File.exists?(Path.join(assets, "js/cinder_ui.js"))
    npm_args = File.read!(Path.join(project, ".npm-args"))
    assert npm_args =~ "install"
    assert npm_args =~ "-D"
    assert npm_args =~ "tailwindcss-animate"
    refute File.exists?(Path.join(assets, ".npm-args"))

    app_css = File.read!(Path.join(assets, "css/app.css"))
    assert app_css =~ "@source \"../../deps/cinder_ui\";"
    assert app_css =~ "@import \"./cinder_ui.css\";"

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "import { CinderUIHooks } from \"./cinder_ui\""
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "creates assets package.json when no package manifests exist", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    assert File.exists?(Path.join(assets, "package.json"))
    assert File.read!(Path.join(assets, "package.json")) =~ "\"private\": true"
    npm_args = File.read!(Path.join(assets, ".npm-args"))
    assert npm_args =~ "install"
    assert npm_args =~ "-D"
    assert npm_args =~ "tailwindcss-animate"
  end

  test "skips package installation when dependency is already declared", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(
      Path.join(project, "package.json"),
      """
      {
        "private": true,
        "devDependencies": {
          "tailwindcss-animate": "^1.0.7"
        }
      }
      """
    )

    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    refute File.exists?(Path.join(project, ".npm-args"))
    refute File.exists?(Path.join(assets, ".npm-args"))
  end

  test "merges Cinder UI hooks into colocated hooks live socket config", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
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

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "import { CinderUIHooks } from \"./cinder_ui\""
    assert app_js =~ "hooks: {...colocatedHooks, ...CinderUIHooks}"
  end

  test "skip-existing preserves generated files", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")
    File.write!(Path.join(assets, "css/cinder_ui.css"), "/* sentinel css */\n")
    File.write!(Path.join(assets, "js/cinder_ui.js"), "// sentinel js\n")

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)

        Mix.Task.run(@task, [
          "--assets-path",
          "assets",
          "--package-manager",
          "npm",
          "--skip-existing"
        ])
      end)
    end)

    assert File.read!(Path.join(assets, "css/cinder_ui.css")) == "/* sentinel css */\n"
    assert File.read!(Path.join(assets, "js/cinder_ui.js")) == "// sentinel js\n"
  end

  test "skip-patching preserves app files", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    original_app_css = "@import \"tailwindcss\";\n/* keep */\n"
    original_app_js = "import {LiveSocket} from \"phoenix_live_view\"\nlet Hooks = {}\n"
    File.write!(Path.join(assets, "css/app.css"), original_app_css)
    File.write!(Path.join(assets, "js/app.js"), original_app_js)

    write_fake_npm!(bin_dir)

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)

        Mix.Task.run(@task, [
          "--assets-path",
          "assets",
          "--package-manager",
          "npm",
          "--skip-patching"
        ])
      end)
    end)

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

  test "missing assets path currently errors while creating package manifest", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    File.mkdir_p!(project)

    assert_raise File.Error, ~r/no such file or directory/, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "missing", "--package-manager", "npm"])
      end)
    end
  end

  test "raises for unsupported package manager", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    File.mkdir_p!(assets)

    assert_raise Mix.Error, ~r/unsupported package manager/, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "nope"])
      end)
    end
  end

  test "auto-detects package manager from lockfile", %{tmp_dir: tmp_dir} do
    Enum.each(
      [
        {"pnpm-lock.yaml", "pnpm", "add -D"},
        {"yarn.lock", "yarn", "add -D"},
        {"bun.lock", "bun", "add -d"},
        {"bun.lockb", "bun", "add -d"}
      ],
      fn {lockfile, pm, expected_args} ->
        project = Path.join(tmp_dir, "project-#{pm}")
        assets = Path.join(project, "assets")
        bin_dir = Path.join(project, "bin")

        File.mkdir_p!(Path.join(assets, "css"))
        File.mkdir_p!(Path.join(assets, "js"))
        File.mkdir_p!(bin_dir)

        File.write!(Path.join(assets, lockfile), "")
        File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
        File.write!(Path.join(assets, "js/app.js"), "let Hooks = {}\n")

        write_fake_pm!(bin_dir, pm)

        with_fake_path(bin_dir, fn ->
          File.cd!(project, fn ->
            Mix.Task.reenable(@task)
            Mix.Task.run(@task, ["--assets-path", "assets"])
          end)
        end)

        args_file = Path.join(assets, ".#{pm}-args")
        assert File.exists?(args_file)
        args = File.read!(args_file)
        assert args =~ String.replace(expected_args, " ", "\n")
        assert args =~ "tailwindcss-animate"
      end
    )
  end

  test "fallback hooks merge branch and command failure branch are handled", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)

    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    File.write!(Path.join(assets, "js/app.js"), "const socket = {}\n")

    write_fake_pm!(bin_dir, "npm", 1)

    assert_raise Mix.Error, ~r/failed to install tailwindcss-animate using npm/, fn ->
      with_fake_path(bin_dir, fn ->
        File.cd!(project, fn ->
          Mix.Task.reenable(@task)
          Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
        end)
      end)
    end

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert app_js =~ "Object.assign(Hooks, CinderUIHooks)"
    assert app_js =~ "window.Hooks = Hooks"
  end

  test "lowercase hooks and pre-merged hooks are preserved correctly", %{tmp_dir: tmp_dir} do
    project = Path.join(tmp_dir, "project")
    assets = Path.join(project, "assets")
    bin_dir = Path.join(project, "bin")

    File.mkdir_p!(Path.join(assets, "css"))
    File.mkdir_p!(Path.join(assets, "js"))
    File.mkdir_p!(bin_dir)
    File.write!(Path.join(project, "package.json"), "{\n  \"private\": true\n}\n")
    File.write!(Path.join(assets, "css/app.css"), "@import \"tailwindcss\";\n")
    write_fake_npm!(bin_dir)

    File.write!(Path.join(assets, "js/app.js"), "let hooks = {}\n")

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    assert File.read!(Path.join(assets, "js/app.js")) =~ "Object.assign(hooks, CinderUIHooks)"

    File.write!(
      Path.join(assets, "js/app.js"),
      """
      import { CinderUIHooks } from "./cinder_ui"
      const liveSocket = new LiveSocket("/live", Socket, {
        hooks: {...colocatedHooks, ...CinderUIHooks},
      })
      """
    )

    with_fake_path(bin_dir, fn ->
      File.cd!(project, fn ->
        Mix.Task.reenable(@task)
        Mix.Task.run(@task, ["--assets-path", "assets", "--package-manager", "npm"])
      end)
    end)

    app_js = File.read!(Path.join(assets, "js/app.js"))
    assert String.split(app_js, "...CinderUIHooks") |> length() == 2
  end

  defp with_fake_path(bin_dir, fun) do
    original = System.get_env("PATH") || ""
    System.put_env("PATH", "#{bin_dir}:#{original}")

    try do
      fun.()
    after
      System.put_env("PATH", original)
    end
  end

  defp write_fake_npm!(bin_dir) do
    write_fake_pm!(bin_dir, "npm")
  end

  defp write_fake_pm!(bin_dir, name, status \\ 0) do
    path = Path.join(bin_dir, name)
    args_file = ".#{name}-args"

    script = """
    #!/bin/sh
    printf "%s\\n" "$@" > "$PWD/#{args_file}"
    #{if(status == 0, do: "echo ok", else: "echo failed >&2")}
    exit #{status}
    """

    File.write!(path, script)
    File.chmod!(path, 0o755)
  end
end
