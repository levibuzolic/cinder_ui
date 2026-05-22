defmodule CinderUI.Components.Delegation do
  @moduledoc false

  @docs_base_url "https://levibuzolic.github.io/cinder_ui/docs"

  def components(component_modules) do
    Enum.reduce(component_modules, %{}, fn {module, functions}, acc ->
      module_components = module.__components__()

      selected_components =
        Map.take(module_components, functions)

      Map.merge(acc, selected_components)
    end)
  end

  def component_doc(module, facade, function) do
    source_component_doc(module, facade, function) ||
      compiled_component_doc(module, facade, function) ||
      false
  end

  defp compiled_component_doc(module, facade, function) do
    Code.ensure_compiled!(module)

    with {:docs_v1, _, _, _, _, _, docs} <- Code.fetch_docs(module),
         {{:function, ^function, 1}, _, _, %{"en" => doc}, _} when is_binary(doc) <-
           Enum.find(docs, &doc_entry?(&1, function)) do
      rewrite_component_doc(doc, module, facade, function)
    else
      _ -> nil
    end
  end

  defp doc_entry?({{:function, name, 1}, _, _, %{"en" => _}, _}, function), do: name == function
  defp doc_entry?(_, _function), do: false

  defp rewrite_component_doc(doc, module, facade, function) do
    doc
    |> String.replace(component_docs_url(module, function), component_docs_url(facade, function))
    |> String.replace(
      screenshot_markdown_path(module, function),
      screenshot_markdown_path(facade, function)
    )
  end

  defp source_component_doc(module, facade, function) do
    with {:ok, source} <- File.read(component_source_path(module)),
         {:ok, doc} <- extract_source_doc(source, function) do
      doc
      |> String.replace("doc/screenshots/", "screenshots/")
      |> append_screenshot(facade, function)
      |> append_docs_link(facade, function)
    else
      _ -> nil
    end
  end

  defp component_source_path(module) do
    [_cinder_ui, _components | parts] = Module.split(module)

    parts =
      Enum.map(parts, fn part ->
        part
        |> Macro.underscore()
        |> String.replace("_", "-")
      end)

    Path.join(["lib", "cinder_ui", "components" | parts]) <> ".ex"
  end

  defp extract_source_doc(source, function) do
    def_marker = "\n  def #{function}("

    with {def_index, _length} <- :binary.match(source, def_marker),
         prefix <- binary_part(source, 0, def_index),
         [{doc_start, doc_start_length} | _] <-
           :binary.matches(prefix, "\n  doc(\"\"\"\n") |> Enum.reverse(),
         doc_body_start <- doc_start + doc_start_length,
         after_doc_start <-
           binary_part(prefix, doc_body_start, byte_size(prefix) - doc_body_start),
         {doc_end, _doc_end_length} <- :binary.match(after_doc_start, "\n  \"\"\")") do
      {:ok, binary_part(after_doc_start, 0, doc_end)}
    else
      _ -> :error
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

  defp component_docs_url(module, function),
    do: "#{@docs_base_url}/#{component_id(module, function)}/"

  defp screenshot_markdown_path(module, function),
    do: "screenshots/#{component_id(module, function)}.png"

  defp component_id(module, function), do: "#{module_slug(module)}-#{function}"

  defp module_slug(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end
end
