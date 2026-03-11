defmodule Mix.Tasks.CinderUi.Install do
  @shortdoc "Installs Cinder UI assets and Tailwind dependencies"
  @moduledoc """
  Installs Cinder UI into a Phoenix project.

  The task performs the following steps:

  1. Copies `cinder_ui.css` and `cinder_ui.js` into your `assets/` folder.
  2. Updates `assets/css/app.css` with:
     - `@source "../../deps/cinder_ui";`
     - `@import "./cinder_ui.css";`
  3. Updates `assets/js/app.js` to merge Cinder UI LiveView hooks.
  4. Installs `tailwindcss-animate` using your detected or selected package manager.
     When no `package.json` exists in `assets/`, the installer will use the
     project root `package.json` if present, or create a minimal one in `assets/`.

  ## Options

    * `--assets-path` - path to the assets directory (default: `assets`)
    * `--package-manager` - `npm`, `pnpm`, `yarn`, or `bun`
    * `--skip-existing` - do not overwrite Cinder UI generated files if they already exist
    * `--skip-patching` - do not patch `assets/css/app.css` or `assets/js/app.js`

  ## Example

      mix cinder_ui.install --package-manager pnpm
  """

  use Mix.Task

  @template_dir Path.expand("../../../priv/templates", __DIR__)
  @supported_pm ~w(npm pnpm yarn bun)

  @impl true
  def run(argv) do
    {opts, _, _} =
      OptionParser.parse(argv,
        strict: [
          assets_path: :string,
          package_manager: :string,
          skip_existing: :boolean,
          skip_patching: :boolean,
          help: :boolean
        ]
      )

    if opts[:help] do
      Mix.shell().info(@moduledoc)
    else
      assets_path = Path.expand(opts[:assets_path] || "assets", File.cwd!())
      package_install_path = resolve_package_install_path!(assets_path)
      package_manager = normalize_package_manager(opts[:package_manager], package_install_path)
      skip_existing = opts[:skip_existing] || false
      skip_patching = opts[:skip_patching] || false

      ensure_assets_dir!(assets_path)

      install_css!(assets_path, skip_existing)
      install_js!(assets_path, skip_existing)

      unless skip_patching do
        patch_app_css!(assets_path)
        patch_app_js!(assets_path)
      end

      maybe_install_package!(package_install_path, package_manager, "tailwindcss-animate")
      Mix.shell().info("Cinder UI install complete.")
    end
  end

  defp ensure_assets_dir!(assets_path) do
    unless File.dir?(assets_path) do
      Mix.raise("assets path not found: #{assets_path}")
    end
  end

  defp install_css!(assets_path, skip_existing) do
    src = Path.join(@template_dir, "cinder_ui.css")
    target = Path.join([assets_path, "css", "cinder_ui.css"])

    File.mkdir_p!(Path.dirname(target))
    write_generated_file!(target, File.read!(src), skip_existing, "created")
  end

  defp install_js!(assets_path, skip_existing) do
    src = Path.join(@template_dir, "cinder_ui.js")
    target = Path.join([assets_path, "js", "cinder_ui.js"])

    File.mkdir_p!(Path.dirname(target))
    write_generated_file!(target, File.read!(src), skip_existing, "created")
  end

  defp patch_app_css!(assets_path) do
    app_css_path = Path.join([assets_path, "css", "app.css"])

    base_content =
      if File.exists?(app_css_path) do
        File.read!(app_css_path)
      else
        "@import \"tailwindcss\";\n"
      end

    updated_content =
      base_content
      |> ensure_line("@source \"../../deps/cinder_ui\";")
      |> ensure_line("@import \"./cinder_ui.css\";")

    write_if_changed!(app_css_path, base_content, updated_content)
  end

  defp patch_app_js!(assets_path) do
    app_js_path = Path.join([assets_path, "js", "app.js"])

    base_content =
      if File.exists?(app_js_path) do
        File.read!(app_js_path)
      else
        "import { LiveSocket } from \"phoenix_live_view\"\nlet Hooks = {}\n"
      end

    updated_content =
      base_content
      |> ensure_line("import { CinderUIHooks } from \"./cinder_ui\"")
      |> inject_hooks_merge()

    write_if_changed!(app_js_path, base_content, updated_content)
  end

  defp inject_hooks_merge(content) do
    cond do
      String.contains?(content, "...CinderUIHooks") ->
        content

      Regex.match?(~r/hooks:\s*\{\s*\.\.\.colocatedHooks\s*\}/, content) ->
        Regex.replace(
          ~r/hooks:\s*\{\s*\.\.\.colocatedHooks\s*\}/,
          content,
          "hooks: {...colocatedHooks, ...CinderUIHooks}"
        )

      String.contains?(content, "Object.assign(Hooks, CinderUIHooks)") ->
        content

      String.contains?(content, "let Hooks = {}") ->
        String.replace(
          content,
          "let Hooks = {}",
          "let Hooks = {}\nObject.assign(Hooks, CinderUIHooks)"
        )

      String.contains?(content, "let hooks = {}") ->
        String.replace(
          content,
          "let hooks = {}",
          "let hooks = {}\nObject.assign(hooks, CinderUIHooks)"
        )

      true ->
        content <>
          "\nlet Hooks = window.Hooks || {}\nObject.assign(Hooks, CinderUIHooks)\nwindow.Hooks = Hooks\n"
    end
  end

  defp ensure_line(content, line) do
    if String.contains?(content, line),
      do: content,
      else: String.trim_trailing(content) <> "\n" <> line <> "\n"
  end

  defp write_if_changed!(path, content, content) do
    Mix.shell().info("already up to date #{relative(path)}")
  end

  defp write_if_changed!(path, _old_content, new_content) do
    File.write!(path, new_content)
    Mix.shell().info("updated #{relative(path)}")
  end

  defp maybe_install_package!(install_path, package_manager, package) do
    if package_installed?(install_path, package) do
      Mix.shell().info("already present #{package} (in #{relative(install_path)})")
      :ok
    else
      {cmd, args} = package_command(package_manager, package)
      Mix.shell().info("running #{cmd} #{Enum.join(args, " ")} (in #{relative(install_path)})")
      {output, status} = System.cmd(cmd, args, cd: install_path, stderr_to_stdout: true)

      if status == 0 do
        Mix.shell().info(String.trim(output))
      else
        Mix.shell().error(String.trim(output))
        Mix.raise("failed to install #{package} using #{package_manager}")
      end
    end
  end

  defp package_installed?(install_path, package) do
    package_json_path = Path.join(install_path, "package.json")

    with true <- File.exists?(package_json_path),
         {:ok, content} <- File.read(package_json_path),
         {:ok, package_json} <- Jason.decode(content) do
      declared_dependency?(package_json["dependencies"], package) ||
        declared_dependency?(package_json["devDependencies"], package)
    else
      _ -> false
    end
  end

  defp declared_dependency?(dependencies, package) when is_map(dependencies) do
    Map.has_key?(dependencies, package)
  end

  defp declared_dependency?(_, _package), do: false

  defp resolve_package_install_path!(assets_path) do
    assets_package_json = Path.join(assets_path, "package.json")
    project_path = Path.dirname(assets_path)
    project_package_json = Path.join(project_path, "package.json")

    cond do
      File.exists?(assets_package_json) ->
        assets_path

      File.exists?(project_package_json) ->
        project_path

      true ->
        File.write!(assets_package_json, "{\n  \"private\": true\n}\n")
        Mix.shell().info("created #{relative(assets_package_json)}")
        assets_path
    end
  end

  defp package_command("npm", package), do: {"npm", ["install", "-D", package]}
  defp package_command("pnpm", package), do: {"pnpm", ["add", "-D", package]}
  defp package_command("yarn", package), do: {"yarn", ["add", "-D", package]}
  defp package_command("bun", package), do: {"bun", ["add", "-d", package]}

  defp write_generated_file!(path, content, true, verb) do
    if File.exists?(path) do
      Mix.shell().info("skipped existing #{relative(path)}")
    else
      File.write!(path, content)
      Mix.shell().info("#{verb} #{relative(path)}")
    end
  end

  defp write_generated_file!(path, content, false, verb) do
    File.write!(path, content)
    Mix.shell().info("#{verb} #{relative(path)}")
  end

  defp normalize_package_manager(nil, assets_path) do
    cond do
      File.exists?(Path.join(assets_path, "pnpm-lock.yaml")) -> "pnpm"
      File.exists?(Path.join(assets_path, "yarn.lock")) -> "yarn"
      File.exists?(Path.join(assets_path, "bun.lock")) -> "bun"
      File.exists?(Path.join(assets_path, "bun.lockb")) -> "bun"
      true -> "npm"
    end
  end

  defp normalize_package_manager(value, _assets_path) when value in @supported_pm, do: value

  defp normalize_package_manager(value, _assets_path) do
    Mix.raise(
      "unsupported package manager: #{inspect(value)}. Expected one of #{Enum.join(@supported_pm, ", ")}"
    )
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
