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
    * `--dry-run` - print planned changes without writing files or installing packages

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
          dry_run: :boolean,
          help: :boolean
        ]
      )

    if opts[:help] do
      Mix.shell().info(@moduledoc)
    else
      assets_path = Path.expand(opts[:assets_path] || "assets", File.cwd!())
      dry_run = opts[:dry_run] || false
      package_install_path = resolve_package_install_path!(assets_path, dry_run)
      package_manager = normalize_package_manager(opts[:package_manager], package_install_path)
      skip_existing = opts[:skip_existing] || false
      skip_patching = opts[:skip_patching] || false

      ensure_assets_dir!(assets_path)

      install_css!(assets_path, skip_existing, dry_run)
      install_js!(assets_path, skip_existing, dry_run)

      unless skip_patching do
        patch_app_css!(assets_path, dry_run)
        patch_app_js!(assets_path, dry_run)
      end

      maybe_install_package!(
        package_install_path,
        package_manager,
        "tailwindcss-animate",
        dry_run
      )

      Mix.shell().info(
        if(dry_run, do: "Cinder UI dry run complete.", else: "Cinder UI install complete.")
      )
    end
  end

  defp ensure_assets_dir!(assets_path) do
    unless File.dir?(assets_path) do
      Mix.raise("assets path not found: #{assets_path}")
    end
  end

  defp install_css!(assets_path, skip_existing, dry_run) do
    src = Path.join(@template_dir, "cinder_ui.css")
    target = Path.join([assets_path, "css", "cinder_ui.css"])

    unless dry_run do
      File.mkdir_p!(Path.dirname(target))
    end

    write_generated_file!(target, File.read!(src), skip_existing, "created", dry_run)
  end

  defp install_js!(assets_path, skip_existing, dry_run) do
    src = Path.join(@template_dir, "cinder_ui.js")
    target = Path.join([assets_path, "js", "cinder_ui.js"])

    unless dry_run do
      File.mkdir_p!(Path.dirname(target))
    end

    write_generated_file!(target, File.read!(src), skip_existing, "created", dry_run)
  end

  defp patch_app_css!(assets_path, dry_run) do
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

    write_if_changed!(app_css_path, base_content, updated_content, dry_run)
  end

  defp patch_app_js!(assets_path, dry_run) do
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

    write_if_changed!(app_js_path, base_content, updated_content, dry_run)
  end

  defp inject_hooks_merge(content) do
    cond do
      String.contains?(content, "...CinderUIHooks") or
          String.contains?(content, "Object.assign(Hooks, CinderUIHooks)") ->
        content

      Regex.match?(~r/hooks:\s*\{(?<hooks_body>[^}]*)\}/s, content) ->
        merge_hooks_object(content)

      Regex.match?(~r/hooks:\s*\{\s*\.\.\.colocatedHooks\s*\}/, content) ->
        Regex.replace(
          ~r/hooks:\s*\{\s*\.\.\.colocatedHooks\s*\}/,
          content,
          "hooks: {...colocatedHooks, ...CinderUIHooks}"
        )

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
        append_hooks_fallback(content)
    end
  end

  defp merge_hooks_object(content) do
    Regex.replace(~r/hooks:\s*\{(?<hooks_body>[^}]*)\}/s, content, fn _match, hooks_body ->
      "hooks: {#{merged_hooks_body(hooks_body)}}"
    end)
  end

  defp merged_hooks_body(hooks_body) do
    hooks_body
    |> String.trim()
    |> case do
      "" ->
        "...CinderUIHooks"

      trimmed when String.ends_with?(trimmed, ",") ->
        "#{String.trim_trailing(hooks_body)} ...CinderUIHooks"

      _trimmed ->
        "#{String.trim_trailing(hooks_body)}, ...CinderUIHooks"
    end
  end

  defp append_hooks_fallback(content) do
    content <>
      "\nlet Hooks = window.Hooks || {}\nObject.assign(Hooks, CinderUIHooks)\nwindow.Hooks = Hooks\n"
  end

  defp ensure_line(content, line) do
    if String.contains?(content, line),
      do: content,
      else: String.trim_trailing(content) <> "\n" <> line <> "\n"
  end

  defp write_if_changed!(path, content, content, _dry_run) do
    Mix.shell().info("already up to date #{relative(path)}")
  end

  defp write_if_changed!(path, _old_content, _new_content, true) do
    Mix.shell().info("would update #{relative(path)}")
  end

  defp write_if_changed!(path, _old_content, new_content, false) do
    File.write!(path, new_content)
    Mix.shell().info("updated #{relative(path)}")
  end

  defp maybe_install_package!(install_path, package_manager, package, dry_run) do
    cond do
      package_installed?(install_path, package) ->
        Mix.shell().info("already present #{package} (in #{relative(install_path)})")
        :ok

      dry_run ->
        {cmd, args} = package_command(package_manager, package)

        Mix.shell().info(
          "would run #{cmd} #{Enum.join(args, " ")} (in #{relative(install_path)})"
        )

        :ok

      true ->
        install_package!(install_path, package_manager, package)
    end
  end

  defp install_package!(install_path, package_manager, package) do
    {cmd, args} = package_command(package_manager, package)
    Mix.shell().info("running #{cmd} #{Enum.join(args, " ")} (in #{relative(install_path)})")

    {output, status} = System.cmd(cmd, args, cd: install_path, stderr_to_stdout: true)

    case status do
      0 ->
        Mix.shell().info(String.trim(output))

      _ ->
        Mix.shell().error(String.trim(output))
        Mix.raise("failed to install #{package} using #{package_manager}")
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

  defp resolve_package_install_path!(assets_path, dry_run) do
    assets_package_json = Path.join(assets_path, "package.json")
    project_path = Path.dirname(assets_path)
    project_package_json = Path.join(project_path, "package.json")

    cond do
      File.exists?(assets_package_json) ->
        assets_path

      File.exists?(project_package_json) ->
        project_path

      true ->
        if dry_run do
          Mix.shell().info("would create #{relative(assets_package_json)}")
        else
          File.write!(assets_package_json, "{\n  \"private\": true\n}\n")
          Mix.shell().info("created #{relative(assets_package_json)}")
        end

        assets_path
    end
  end

  defp package_command("npm", package), do: {"npm", ["install", "-D", package]}
  defp package_command("pnpm", package), do: {"pnpm", ["add", "-D", package]}
  defp package_command("yarn", package), do: {"yarn", ["add", "-D", package]}
  defp package_command("bun", package), do: {"bun", ["add", "-d", package]}

  defp write_generated_file!(path, _content, true, _verb, true) do
    if File.exists?(path) do
      Mix.shell().info("would skip existing #{relative(path)}")
    else
      Mix.shell().info("would create #{relative(path)}")
    end
  end

  defp write_generated_file!(path, content, true, verb, false) do
    if File.exists?(path) do
      Mix.shell().info("skipped existing #{relative(path)}")
    else
      File.write!(path, content)
      Mix.shell().info("#{verb} #{relative(path)}")
    end
  end

  defp write_generated_file!(path, _content, false, _verb, true) do
    action = if File.exists?(path), do: "would update", else: "would create"
    Mix.shell().info("#{action} #{relative(path)}")
  end

  defp write_generated_file!(path, content, false, verb, false) do
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
