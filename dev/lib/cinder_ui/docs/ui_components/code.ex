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
      |> assign(:highlighted_html, CodeHighlighter.highlight(assigns.source, assigns.language))
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
      <code id={@id} class={classes(@code_classes)}><%= HTML.raw(@highlighted_html) %></code>
    </pre>
    """
  end

  def summary_markdown_html(text) do
    text
    |> ExDoc.Markdown.to_ast(markdown_processor: ExDoc.Markdown.Earmark)
    |> ExDoc.DocAST.map_tags(&highlight_markdown_code/1)
    |> ExDoc.DocAST.to_html()
  rescue
    _ ->
      "<p>#{text |> HTML.html_escape() |> HTML.safe_to_string()}</p>"
  end

  defp highlight_markdown_code({:pre, attrs, [{:code, code_attrs, [source], meta}], pre_meta})
       when is_binary(source) do
    language =
      Map.get(
        %{"elixir" => :elixir, "heex" => :heex, "html" => :heex, "css" => :css, "bash" => :bash},
        Keyword.get(code_attrs, :class),
        :plain
      )

    code_attrs = Keyword.update(code_attrs, :class, "code-highlight", &("code-highlight " <> &1))
    highlighted = CodeHighlighter.highlight(source, language)
    code = {:code, code_attrs, [highlighted], Map.put(meta, :verbatim, true)}
    {:pre, attrs, [code], pre_meta}
  end

  defp highlight_markdown_code(node), do: node
end
