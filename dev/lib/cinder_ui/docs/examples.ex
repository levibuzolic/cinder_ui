defmodule CinderUI.Docs.Examples do
  @moduledoc false

  alias CinderUI.Docs.PreviewRenderer

  def build(module, function, []) do
    raise ArgumentError,
          "missing inline docs example for #{inspect(module)}.#{function}/1"
  end

  def build(module, function, inline_doc_examples) do
    inline_doc_examples
    |> Enum.with_index(1)
    |> Enum.map(fn {example, index} ->
      template_heex = normalize_template_heex(example.template_heex)
      display_template_heex = sanitize_template_heex_for_display(template_heex)

      %{
        id: normalize_example_id(example.id, index),
        title: doc_example_title(example.title, function, index),
        description: nil,
        preview_html: PreviewRenderer.render(module, function, template_heex),
        template_heex: display_template_heex,
        preview_align: example.preview_align || :center,
        promoted_visual: Map.get(example, :promoted_visual, false),
        phoenix_shim: Map.get(example, :phoenix_shim, false)
      }
    end)
  end

  defp normalize_template_heex(template_heex) when is_binary(template_heex) do
    template_heex
    |> String.replace(~r/<\s*CinderUI\.Icons\.icon\b/u, "<.icon")
    |> String.replace(~r/<\/\s*CinderUI\.Icons\.icon\s*>/u, "</.icon>")
  end

  defp sanitize_template_heex_for_display(template_heex) when is_binary(template_heex) do
    template_heex
    |> String.trim()
    |> String.replace(~r/"data:[^"]*"/u, "\"example.png\"")
    |> String.replace(~r/'data:[^']*'/u, "'example.png'")
  end

  defp normalize_example_id(nil, index), do: "example-#{index}"

  defp normalize_example_id(id, index) do
    id
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
    |> case do
      "" -> "example-#{index}"
      value -> value
    end
  end

  defp doc_example_title(nil, function, index),
    do: "#{humanize_function(function)} example #{index}"

  defp doc_example_title(title, function, index) do
    if String.starts_with?(title, "Inline docs example") do
      "#{humanize_function(function)} example #{index}"
    else
      title
    end
  end

  defp humanize_function(function) do
    function
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
