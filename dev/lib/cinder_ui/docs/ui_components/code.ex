defmodule CinderUI.Docs.UIComponents.Code do
  @moduledoc false

  use Phoenix.Component

  import CinderUI.Classes

  alias CinderUI.Docs.CodeHighlighter
  alias Phoenix.HTML

  attr :id, :string, default: nil
  attr :source, :string, required: true
  attr :language, :atom, default: :auto
  attr :standalone, :boolean, default: false
  attr :pre_class, :any, default: nil
  attr :code_class, :any, default: nil
  attr :rest, :global

  def docs_code_block(assigns) do
    assigns =
      assigns
      |> assign(:highlighted_html, highlighted_code_html(assigns.source, assigns.language))
      |> assign(:pre_classes, [
        "overflow-x-auto rounded-lg bg-muted/30 p-4 text-xs whitespace-normal",
        assigns.standalone && "install-code-block relative rounded-xl my-4 border text-sm"
        | List.wrap(assigns.pre_class)
      ])
      |> assign(:code_classes, [
        "code-highlight block min-w-max whitespace-pre" | List.wrap(assigns.code_class)
      ])

    ~H"""
    <pre class={classes(@pre_classes)} {@rest}>
      <code id={@id} class={classes(@code_classes)}><%= rendered(@highlighted_html) %></code>
    </pre>
    """
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp highlighted_code_html(source, language) do
    CodeHighlighter.highlight(source, language)
  end

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()

  def summary_markdown_html(text) do
    text
    |> ExDoc.Markdown.to_ast(markdown_processor: ExDoc.Markdown.Earmark)
    |> ExDoc.DocAST.to_html()
  rescue
    _ ->
      "<p>#{escape(text)}</p>"
  end
end
