defmodule CinderUI.ComponentDocs do
  @moduledoc false

  @docs_base_url "https://levibuzolic.github.io/cinder_ui/docs"

  @doc false
  @spec component_docs_url(module(), atom()) :: String.t()
  def component_docs_url(module, function) when is_atom(module) and is_atom(function) do
    "#{@docs_base_url}/#{component_id(module, function)}/"
  end

  @doc false
  @spec section_docs_url(module()) :: String.t()
  def section_docs_url(module) when is_atom(module) do
    "#{@docs_base_url}/##{module_slug(module)}"
  end

  @spec screenshot_markdown_path(module(), atom()) :: String.t()
  defp screenshot_markdown_path(module, function) when is_atom(module) and is_atom(function) do
    "screenshots/#{component_id(module, function)}.png"
  end

  @spec component_id(module(), atom()) :: String.t()
  defp component_id(module, function) when is_atom(module) and is_atom(function) do
    "#{module_slug(module)}-#{function}"
  end

  @spec module_slug(module()) :: String.t()
  defp module_slug(module) when is_atom(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end

  @doc false
  defmacro doc(markdown) do
    updated_markdown = append_generated_sections(markdown, __CALLER__)

    quote do
      @doc unquote(updated_markdown)
    end
  end

  defp append_generated_sections(markdown, _env) when not is_binary(markdown), do: markdown

  defp append_generated_sections(markdown, env) do
    markdown = String.replace(markdown, "doc/screenshots/", "screenshots/")

    case documented_function(env.file, env.line) do
      nil ->
        markdown

      function ->
        markdown
        |> append_screenshot(env.module, function)
        |> append_docs_link(env.module, function)
    end
  end

  defp append_docs_link(markdown, module, function) do
    docs_url = component_docs_url(module, function)

    if String.contains?(markdown, docs_url) do
      markdown
    else
      String.trim_trailing(markdown) <>
        "\n\n[View live examples and full component docs](#{docs_url}).\n"
    end
  end

  defp append_screenshot(markdown, module, function) do
    screenshot_path = screenshot_markdown_path(module, function)

    if String.contains?(markdown, screenshot_path) do
      markdown
    else
      String.trim_trailing(markdown) <>
        "\n\n## Screenshot\n\n![#{function}/1 screenshot](#{screenshot_path})\n"
    end
  end

  defp documented_function(file, doc_line) do
    file
    |> File.stream!()
    |> Enum.drop(doc_line)
    |> Enum.find_value(fn line ->
      case Regex.run(~r/^\s*def\s+([a-zA-Z0-9_!?]+)\s*\(/, line, capture: :all_but_first) do
        [function_name] -> String.to_atom(function_name)
        _ -> nil
      end
    end)
  end
end
