defmodule Mix.Tasks.CinderUi.Install do
  @shortdoc "Wires Cinder UI's CSS and JavaScript into a Phoenix project"
  @moduledoc """
  Installs Cinder UI into a Phoenix project.

  Cinder UI's CSS and JavaScript are referenced directly from `deps/cinder_ui` —
  nothing is copied into your project, and there is no npm package to install
  (the `tailwindcss-animate` utilities are inlined into Cinder UI's CSS). The
  task performs two edits:

  1. Updates `assets/css/app.css` with:
     - `@source "../../deps/cinder_ui";`
     - `@import "../../deps/cinder_ui/priv/templates/cinder_ui.css";`
  2. Updates `assets/js/app.js` to import `CinderUIHooks` from the `cinder_ui`
     package (resolved via Phoenix's default esbuild `NODE_PATH`) and merges
     them into your LiveView hooks.

  Because the referenced files live in `deps/cinder_ui`, they update
  automatically whenever you upgrade the dependency — no re-run required.

  ## Doing it by hand

  The CSS edit is just two lines. If you would rather not run the task, add them
  to `assets/css/app.css` yourself (after `@import "tailwindcss";`):

      @source "../../deps/cinder_ui";
      @import "../../deps/cinder_ui/priv/templates/cinder_ui.css";

  Then import the hooks in `assets/js/app.js` and merge them into your LiveView
  hooks:

      import { CinderUIHooks } from "cinder_ui"
      // ...
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { ...CinderUIHooks },
        // ...
      })

  ## Options

    * `--assets-path` - path to the assets directory (default: `assets`)
    * `--skip-patching` - do not patch `assets/css/app.css` or `assets/js/app.js`
    * `--dry-run` - print planned changes without writing files

  ## Example

      mix cinder_ui.install
      mix cinder_ui.install --assets-path assets
  """

  use Mix.Task

  @impl true
  def run(argv) do
    {opts, args, invalid} =
      OptionParser.parse(argv,
        strict: [
          assets_path: :string,
          skip_patching: :boolean,
          dry_run: :boolean,
          help: :boolean
        ]
      )

    cond do
      invalid != [] ->
        options = Enum.map_join(invalid, ", ", fn {option, _value} -> option end)
        Mix.raise("unknown option or invalid value: #{options}")

      args != [] ->
        Mix.raise("unexpected argument(s): #{Enum.join(args, ", ")}")

      opts[:help] ->
        Mix.shell().info(@moduledoc)

      true ->
        install(opts)
    end
  end

  defp install(opts) do
    assets_path = Path.expand(opts[:assets_path] || "assets", File.cwd!())
    dry_run = opts[:dry_run] || false
    skip_patching = opts[:skip_patching] || false

    ensure_assets_dir!(assets_path)

    unless skip_patching do
      patch_app_css!(assets_path, dry_run)
      patch_app_js!(assets_path, dry_run)
    end

    print_completion(dry_run)
  end

  defp print_completion(true), do: Mix.shell().info("Cinder UI dry run complete.")
  defp print_completion(false), do: Mix.shell().info("Cinder UI install complete.")

  defp ensure_assets_dir!(assets_path) do
    unless File.dir?(assets_path) do
      Mix.raise("assets path not found: #{assets_path}")
    end
  end

  @css_source "@source \"../../deps/cinder_ui\";"
  @css_import "@import \"../../deps/cinder_ui/priv/templates/cinder_ui.css\";"
  @js_import "import { CinderUIHooks } from \"cinder_ui\""

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
      |> ensure_line(@css_source)
      |> ensure_line(@css_import)

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
      |> ensure_js_import()
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
    code = strip_js_tokens(content)

    String.contains?(code, "...CinderUIHooks") or
      Regex.match?(
        ~r/Object\.assign\(\s*[_$[:alpha:]][_$[:alnum:]]*\s*,\s*CinderUIHooks\s*\)/,
        code
      )
  end

  defp ensure_js_import(content) do
    import_pattern =
      ~r/\bimport\s*\{\s*CinderUIHooks\s*\}\s*from\s*["']cinder_ui["']/

    imported? =
      import_pattern
      |> Regex.scan(content, return: :index, capture: :first)
      |> Enum.any?(fn [{index, _length}] -> js_code_index?(content, index) end)

    if imported? do
      content
    else
      String.trim_trailing(content) <> "\n" <> @js_import <> "\n"
    end
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

  defp find_hooks_object_literal(content), do: find_live_socket_hooks_object_literal(content, 0)

  defp find_live_socket_hooks_object_literal(content, index) when index >= byte_size(content),
    do: :error

  defp find_live_socket_hooks_object_literal(content, index) do
    case skip_js_token(content, index) do
      {:ok, next_index} ->
        find_live_socket_hooks_object_literal(content, next_index)

      :cont ->
        if live_socket_call_at?(content, index) do
          find_hooks_in_live_socket_call(content, index)
        else
          find_live_socket_hooks_object_literal(content, index + 1)
        end
    end
  end

  defp find_hooks_in_live_socket_call(content, index) do
    open_index = skip_whitespace(content, index + byte_size("LiveSocket"))

    with true <- byte_at?(content, open_index, ?(),
         {:ok, close_index} <- find_matching_parenthesis(content, open_index),
         {:ok, _, _} = result <- find_hooks_object_literal(content, open_index + 1, close_index) do
      result
    else
      _ -> find_live_socket_hooks_object_literal(content, index + byte_size("LiveSocket"))
    end
  end

  defp find_hooks_object_literal(_content, index, limit) when index >= limit, do: :error

  defp find_hooks_object_literal(content, index, limit) do
    case hooks_property_end(content, index) do
      {:ok, property_end} ->
        maybe_hooks_object_literal(content, property_end, limit)

      :error ->
        case skip_js_token(content, index) do
          {:ok, next_index} ->
            find_hooks_object_literal(content, next_index, limit)

          :cont ->
            find_hooks_object_literal(content, index + 1, limit)
        end
    end
  end

  defp maybe_hooks_object_literal(content, property_end, limit) do
    property_end = skip_whitespace(content, property_end)

    value_index =
      case skip_colon(content, property_end) do
        {:ok, after_colon} -> skip_whitespace(content, after_colon)
        :error -> :error
      end

    with object_index when is_integer(object_index) <- value_index,
         true <- byte_at?(content, object_index, ?{),
         {:ok, close_index} <- find_matching_brace(content, object_index),
         true <- close_index < limit do
      {:ok, object_index, close_index}
    else
      _ -> find_hooks_object_literal(content, property_end, limit)
    end
  end

  defp live_socket_call_at?(content, index) do
    starts_with?(content, index, "LiveSocket") and
      identifier_boundary_before?(content, index) and
      identifier_boundary_after?(content, index + byte_size("LiveSocket"))
  end

  defp hooks_property_at?(content, index) do
    starts_with?(content, index, "hooks") and
      identifier_boundary_before?(content, index) and
      identifier_boundary_after?(content, index + byte_size("hooks"))
  end

  defp hooks_property_end(content, index) do
    cond do
      hooks_property_at?(content, index) -> {:ok, index + byte_size("hooks")}
      starts_with?(content, index, ~s("hooks")) -> {:ok, index + byte_size(~s("hooks"))}
      starts_with?(content, index, ~s('hooks')) -> {:ok, index + byte_size(~s('hooks'))}
      true -> :error
    end
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
    regex = ~r/\b(?:let|const|var)\s+#{hooks_name}\s*=\s*\{\s*\}[ \t]*;?/

    match =
      regex
      |> Regex.scan(content, return: :index, capture: :first)
      |> Enum.find(fn [{index, _length}] -> js_code_index?(content, index) end)

    case match do
      [{index, length}] ->
        declaration = binary_part(content, index, length)
        replacement = "#{declaration}\nObject.assign(#{hooks_name}, CinderUIHooks)"

        binary_part(content, 0, index) <>
          replacement <>
          binary_part(content, index + length, byte_size(content) - index - length)

      nil ->
        nil
    end
  end

  defp append_hooks_fallback(content) do
    content <>
      "\nlet Hooks = window.Hooks || {}\nObject.assign(Hooks, CinderUIHooks)\nwindow.Hooks = Hooks\n"
  end

  defp find_matching_brace(content, open_index) do
    find_matching_brace(content, open_index + 1, 1)
  end

  defp find_matching_parenthesis(content, open_index) do
    find_matching_parenthesis(content, open_index + 1, 1)
  end

  defp find_matching_parenthesis(content, index, _depth) when index >= byte_size(content),
    do: :error

  defp find_matching_parenthesis(content, index, depth) do
    case skip_js_token(content, index) do
      {:ok, next_index} ->
        find_matching_parenthesis(content, next_index, depth)

      :cont ->
        advance_matching_parenthesis(content, index, depth)
    end
  end

  defp advance_matching_parenthesis(content, index, depth) do
    cond do
      byte_at?(content, index, ?() ->
        find_matching_parenthesis(content, index + 1, depth + 1)

      byte_at?(content, index, ?)) and depth == 1 ->
        {:ok, index}

      byte_at?(content, index, ?)) ->
        find_matching_parenthesis(content, index + 1, depth - 1)

      true ->
        find_matching_parenthesis(content, index + 1, depth)
    end
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
    case js_token(content, index) do
      {_kind, next_index} -> {:ok, next_index}
      :cont -> :cont
    end
  end

  defp js_token(content, index) do
    cond do
      starts_with?(content, index, "//") ->
        {:comment, skip_line_comment(content, index + 2)}

      starts_with?(content, index, "/*") ->
        {:comment, skip_block_comment(content, index + 2)}

      byte_at?(content, index, ?") ->
        {:quoted, skip_quoted(content, index + 1, ?")}

      byte_at?(content, index, ?') ->
        {:quoted, skip_quoted(content, index + 1, ?')}

      byte_at?(content, index, ?`) ->
        {:quoted, skip_quoted(content, index + 1, ?`)}

      byte_at?(content, index, ?/) and regex_literal_start?(content, index) ->
        {:regex, skip_regex(content, index + 1, false)}

      true ->
        :cont
    end
  end

  defp js_code_index?(content, target), do: js_code_index?(content, 0, target)

  defp js_code_index?(_content, index, target) when index >= target, do: true

  defp js_code_index?(content, index, target) do
    case js_token(content, index) do
      {_kind, next_index} when target < next_index -> false
      {_kind, next_index} -> js_code_index?(content, next_index, target)
      :cont -> js_code_index?(content, index + 1, target)
    end
  end

  defp strip_js_tokens(content), do: strip_js_tokens(content, 0, 0, [])

  defp strip_js_tokens(content, index, segment_start, parts) when index >= byte_size(content) do
    tail = binary_part(content, segment_start, byte_size(content) - segment_start)

    [tail | parts]
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  defp strip_js_tokens(content, index, segment_start, parts) do
    case js_token(content, index) do
      {_kind, next_index} ->
        strip_js_segment(content, index, next_index, segment_start, parts)

      :cont ->
        strip_js_tokens(content, index + 1, segment_start, parts)
    end
  end

  defp strip_js_segment(content, index, next_index, segment_start, parts) do
    segment = binary_part(content, segment_start, index - segment_start)
    strip_js_tokens(content, next_index, next_index, [" ", segment | parts])
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

  defp regex_literal_start?(content, index) do
    case previous_non_whitespace_byte(content, index - 1) do
      nil -> true
      byte -> byte in [?=, ?(, ?[, ?{, ?,, ?:, ?;, ?!, ??, ?&, ?|, ?>]
    end
  end

  defp previous_non_whitespace_byte(_content, index) when index < 0, do: nil

  defp previous_non_whitespace_byte(content, index) do
    byte = byte_at(content, index)

    if byte in [?\s, ?\n, ?\r, ?\t] do
      previous_non_whitespace_byte(content, index - 1)
    else
      byte
    end
  end

  defp skip_regex(content, index, _in_class) when index >= byte_size(content), do: index

  defp skip_regex(content, index, in_class) do
    cond do
      byte_at?(content, index, ?\\) ->
        skip_regex(content, min(index + 2, byte_size(content)), in_class)

      byte_at?(content, index, ?[) ->
        skip_regex(content, index + 1, true)

      byte_at?(content, index, ?]) ->
        skip_regex(content, index + 1, false)

      byte_at?(content, index, ?/) and not in_class ->
        skip_regex_flags(content, index + 1)

      byte_at(content, index) in [?\n, ?\r] ->
        index

      true ->
        skip_regex(content, index + 1, in_class)
    end
  end

  defp skip_regex_flags(content, index) when index >= byte_size(content), do: index

  defp skip_regex_flags(content, index) do
    if byte_at(content, index) in ?a..?z,
      do: skip_regex_flags(content, index + 1),
      else: index
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
    uncommented = Regex.replace(~r/\/\*.*?(?:\*\/|\z)/s, content, "")

    if String.contains?(uncommented, line),
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

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
