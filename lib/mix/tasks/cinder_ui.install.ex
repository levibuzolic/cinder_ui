defmodule Mix.Tasks.CinderUi.Install do
  @shortdoc "Installs Cinder UI assets and Tailwind dependencies"
  @moduledoc """
  Installs Cinder UI into a Phoenix project.

  By default the task references Cinder UI's CSS and JavaScript directly from
  `deps/cinder_ui` — nothing is copied into your project. It performs the
  following steps:

  1. Updates `assets/css/app.css` with:
     - `@source "../../deps/cinder_ui";`
     - `@import "../../deps/cinder_ui/priv/templates/cinder_ui.css";`
  2. Updates `assets/js/app.js` to import `CinderUIHooks` from the `cinder_ui`
     package (resolved via Phoenix's default esbuild `NODE_PATH`) and merges
     them into your LiveView hooks.
  3. Installs `tailwindcss-animate` using your detected or selected package
     manager. When no `package.json` exists in `assets/`, the installer will use
     the project root `package.json` if present, or create a minimal one in
     `assets/`.

  Because the referenced files live in `deps/cinder_ui`, they update
  automatically whenever you upgrade the dependency — no re-run required.

  ## Copy mode

  With `--copy`, the task instead copies `cinder_ui.css` and `cinder_ui.js` into
  your `assets/` folder and patches `app.css`/`app.js` to reference the local
  copies. Use this when you want to customize the shipped files, or when your
  build can't resolve `deps/cinder_ui` (for example a monorepo with a relocated
  `node_modules`).

  In copy mode the files are a snapshot, so after upgrading Cinder UI re-run the
  installer to refresh them. The patch step has already run, so pass
  `--skip-patching` to only refresh the copies:

      mix cinder_ui.install --copy --skip-patching

  ## Options

    * `--copy` - copy `cinder_ui.css`/`cinder_ui.js` into `assets/` and reference
      the local copies instead of `deps/cinder_ui`
    * `--assets-path` - path to the assets directory (default: `assets`)
    * `--package-manager` - `npm`, `pnpm`, `yarn`, or `bun`
    * `--skip-existing` - with `--copy`, do not overwrite copied files if they
      already exist
    * `--skip-patching` - do not patch `assets/css/app.css` or `assets/js/app.js`
    * `--dry-run` - print planned changes without writing files or installing packages

  ## Example

      mix cinder_ui.install
      mix cinder_ui.install --copy --package-manager pnpm
  """

  use Mix.Task

  alias CinderUI.Assets

  @supported_pm ~w(npm pnpm yarn bun)

  @impl true
  def run(argv) do
    {opts, _, _} =
      OptionParser.parse(argv,
        strict: [
          copy: :boolean,
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
      copy = opts[:copy] || false
      package_install_path = resolve_package_install_path!(assets_path, dry_run)
      package_manager = normalize_package_manager(opts[:package_manager], package_install_path)
      skip_existing = opts[:skip_existing] || false
      skip_patching = opts[:skip_patching] || false

      ensure_assets_dir!(assets_path)

      if copy do
        install_css!(assets_path, skip_existing, dry_run)
        install_js!(assets_path, skip_existing, dry_run)
      end

      unless skip_patching do
        patch_app_css!(assets_path, copy, dry_run)
        patch_app_js!(assets_path, copy, dry_run)
      end

      maybe_install_package!(
        package_install_path,
        package_manager,
        "tailwindcss-animate",
        dry_run
      )

      if copy and not dry_run do
        Mix.shell().info(
          "To refresh copied files after upgrading Cinder UI, re-run: " <>
            "mix cinder_ui.install --copy --skip-patching"
        )
      end

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
    target = Path.join([assets_path, "css", "cinder_ui.css"])

    unless dry_run do
      File.mkdir_p!(Path.dirname(target))
    end

    write_generated_file!(target, Assets.cinder_ui_css(), skip_existing, "created", dry_run)
  end

  defp install_js!(assets_path, skip_existing, dry_run) do
    target = Path.join([assets_path, "js", "cinder_ui.js"])

    unless dry_run do
      File.mkdir_p!(Path.dirname(target))
    end

    write_generated_file!(target, Assets.cinder_ui_js(), skip_existing, "created", dry_run)
  end

  @copy_css_import "@import \"./cinder_ui.css\";"
  @deps_css_import "@import \"../../deps/cinder_ui/priv/templates/cinder_ui.css\";"
  @copy_js_import "import { CinderUIHooks } from \"./cinder_ui\""
  @deps_js_import "import { CinderUIHooks } from \"cinder_ui\""

  defp patch_app_css!(assets_path, copy, dry_run) do
    app_css_path = Path.join([assets_path, "css", "app.css"])

    base_content =
      if File.exists?(app_css_path) do
        File.read!(app_css_path)
      else
        "@import \"tailwindcss\";\n"
      end

    css_import = if copy, do: @copy_css_import, else: @deps_css_import

    updated_content =
      base_content
      |> ensure_line("@source \"../../deps/cinder_ui\";")
      |> ensure_line(css_import)

    write_if_changed!(app_css_path, base_content, updated_content, dry_run)
  end

  defp patch_app_js!(assets_path, copy, dry_run) do
    app_js_path = Path.join([assets_path, "js", "app.js"])

    base_content =
      if File.exists?(app_js_path) do
        File.read!(app_js_path)
      else
        "import { LiveSocket } from \"phoenix_live_view\"\nlet Hooks = {}\n"
      end

    js_import = if copy, do: @copy_js_import, else: @deps_js_import

    updated_content =
      base_content
      |> ensure_line(js_import)
      |> inject_hooks_merge()

    write_if_changed!(app_js_path, base_content, updated_content, dry_run)
  end

  defp inject_hooks_merge(content) do
    cond do
      cinder_ui_hooks_integrated?(content) ->
        content

      patched = patch_hooks_object_literal(content) ->
        patched

      patched = patch_empty_hooks_binding(content, "Hooks") ->
        patched

      patched = patch_empty_hooks_binding(content, "hooks") ->
        patched

      true ->
        append_hooks_fallback(content)
    end
  end

  defp cinder_ui_hooks_integrated?(content) do
    String.contains?(content, "...CinderUIHooks") or
      Regex.match?(
        ~r/Object\.assign\(\s*[_$[:alpha:]][_$[:alnum:]]*\s*,\s*CinderUIHooks\s*\)/,
        content
      )
  end

  defp patch_hooks_object_literal(content) do
    case find_hooks_object_literal(content) do
      {:ok, open_index, close_index} ->
        body_start = open_index + 1
        body_length = close_index - body_start
        body = binary_part(content, body_start, body_length)
        replacement = merge_hooks_object_body(body)

        binary_part(content, 0, body_start) <>
          replacement <>
          binary_part(content, close_index, byte_size(content) - close_index)

      :error ->
        nil
    end
  end

  defp find_hooks_object_literal(content), do: find_hooks_object_literal(content, 0)

  defp find_hooks_object_literal(content, index) when index >= byte_size(content), do: :error

  defp find_hooks_object_literal(content, index) do
    case skip_js_token(content, index) do
      {:ok, next_index} ->
        find_hooks_object_literal(content, next_index)

      :cont ->
        if hooks_property_at?(content, index) do
          maybe_hooks_object_literal(content, index)
        else
          find_hooks_object_literal(content, index + 1)
        end
    end
  end

  defp maybe_hooks_object_literal(content, index) do
    property_end = skip_whitespace(content, index + byte_size("hooks"))

    value_index =
      case skip_colon(content, property_end) do
        {:ok, after_colon} -> skip_whitespace(content, after_colon)
        :error -> :error
      end

    with object_index when is_integer(object_index) <- value_index,
         true <- byte_at?(content, object_index, ?{),
         {:ok, close_index} <- find_matching_brace(content, object_index) do
      {:ok, object_index, close_index}
    else
      _ -> find_hooks_object_literal(content, index + byte_size("hooks"))
    end
  end

  defp hooks_property_at?(content, index) do
    starts_with?(content, index, "hooks") and
      identifier_boundary_before?(content, index) and
      identifier_boundary_after?(content, index + byte_size("hooks"))
  end

  defp merge_hooks_object_body(body) do
    trimmed = String.trim(body)

    cond do
      trimmed == "" ->
        "...CinderUIHooks"

      String.contains?(body, "\n") ->
        merge_multiline_hooks_object_body(body, trimmed)

      true ->
        "#{String.trim_trailing(body)}, ...CinderUIHooks"
    end
  end

  defp merge_multiline_hooks_object_body(body, trimmed) do
    separator = if String.ends_with?(trimmed, ","), do: "\n", else: ",\n"

    String.trim_trailing(body) <>
      separator <>
      hooks_object_entry_indent(body) <>
      "...CinderUIHooks" <>
      trailing_whitespace(body)
  end

  defp hooks_object_entry_indent(body) do
    body
    |> String.split("\n")
    |> Enum.find_value("", fn line ->
      if String.trim(line) == "" do
        nil
      else
        line
        |> String.to_charlist()
        |> Enum.take_while(&(&1 in [?\s, ?\t]))
        |> to_string()
      end
    end)
  end

  defp patch_empty_hooks_binding(content, hooks_name) do
    hooks_name = Regex.escape(hooks_name)
    regex = ~r/\b(?:let|const|var)\s+#{hooks_name}\s*=\s*\{\s*\}\s*;?/

    if Regex.match?(regex, content) do
      Regex.replace(
        regex,
        content,
        fn declaration -> "#{declaration}\nObject.assign(#{hooks_name}, CinderUIHooks)" end,
        global: false
      )
    end
  end

  defp append_hooks_fallback(content) do
    content <>
      "\nlet Hooks = window.Hooks || {}\nObject.assign(Hooks, CinderUIHooks)\nwindow.Hooks = Hooks\n"
  end

  defp find_matching_brace(content, open_index) do
    find_matching_brace(content, open_index + 1, 1)
  end

  defp find_matching_brace(content, index, _depth) when index >= byte_size(content), do: :error

  defp find_matching_brace(content, index, depth) do
    case skip_js_token(content, index) do
      {:ok, next_index} ->
        find_matching_brace(content, next_index, depth)

      :cont ->
        advance_matching_brace(content, index, depth)
    end
  end

  defp advance_matching_brace(content, index, depth) do
    cond do
      byte_at?(content, index, ?{) ->
        find_matching_brace(content, index + 1, depth + 1)

      byte_at?(content, index, ?}) and depth == 1 ->
        {:ok, index}

      byte_at?(content, index, ?}) ->
        find_matching_brace(content, index + 1, depth - 1)

      true ->
        find_matching_brace(content, index + 1, depth)
    end
  end

  defp skip_colon(content, index) do
    if byte_at?(content, index, ?:), do: {:ok, index + 1}, else: :error
  end

  defp skip_whitespace(content, index) when index >= byte_size(content), do: index

  defp skip_whitespace(content, index) do
    if byte_at(content, index) in [?\s, ?\n, ?\r, ?\t] do
      skip_whitespace(content, index + 1)
    else
      index
    end
  end

  defp skip_line_comment(content, index) when index >= byte_size(content), do: index

  defp skip_line_comment(content, index) do
    if byte_at?(content, index, ?\n),
      do: index + 1,
      else: skip_line_comment(content, index + 1)
  end

  defp skip_block_comment(content, index) when index >= byte_size(content), do: index

  defp skip_block_comment(content, index) do
    if starts_with?(content, index, "*/"),
      do: index + 2,
      else: skip_block_comment(content, index + 1)
  end

  defp skip_js_token(content, index) do
    cond do
      starts_with?(content, index, "//") ->
        {:ok, skip_line_comment(content, index + 2)}

      starts_with?(content, index, "/*") ->
        {:ok, skip_block_comment(content, index + 2)}

      byte_at?(content, index, ?") ->
        {:ok, skip_quoted(content, index + 1, ?")}

      byte_at?(content, index, ?') ->
        {:ok, skip_quoted(content, index + 1, ?')}

      byte_at?(content, index, ?`) ->
        {:ok, skip_quoted(content, index + 1, ?`)}

      true ->
        :cont
    end
  end

  defp skip_quoted(content, index, _quote) when index >= byte_size(content), do: index

  defp skip_quoted(content, index, quote) do
    cond do
      byte_at?(content, index, ?\\) ->
        skip_quoted(content, min(index + 2, byte_size(content)), quote)

      byte_at?(content, index, quote) ->
        index + 1

      true ->
        skip_quoted(content, index + 1, quote)
    end
  end

  defp identifier_boundary_before?(_content, 0), do: true

  defp identifier_boundary_before?(content, index) do
    not identifier_byte?(byte_at(content, index - 1))
  end

  defp identifier_boundary_after?(content, index) when index >= byte_size(content), do: true

  defp identifier_boundary_after?(content, index) do
    not identifier_byte?(byte_at(content, index))
  end

  defp identifier_byte?(byte) do
    byte in ?a..?z or byte in ?A..?Z or byte in ?0..?9 or byte in [?_, ?$]
  end

  defp trailing_whitespace(value) do
    case Regex.run(~r/\s*$/, value) do
      [whitespace] -> whitespace
      _ -> ""
    end
  end

  defp byte_at?(content, index, byte) when index < byte_size(content) do
    byte_at(content, index) == byte
  end

  defp byte_at?(_content, _index, _byte), do: false

  defp byte_at(content, index), do: :binary.at(content, index)

  defp starts_with?(content, index, value) do
    value_size = byte_size(value)

    index + value_size <= byte_size(content) and
      binary_part(content, index, value_size) == value
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
