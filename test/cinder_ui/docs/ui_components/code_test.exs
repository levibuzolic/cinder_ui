defmodule CinderUI.Docs.UIComponents.CodeTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.UIComponents.Code

  test "renders markdown summaries through ExDoc markdown" do
    html =
      Code.summary_markdown_html("Use `button/1` with [Phoenix](https://phoenixframework.org).")

    assert html =~ ~s(<code class="inline">button/1</code>)
    assert html =~ ~s(<a href="https://phoenixframework.org">Phoenix</a>)
  end

  test "highlights fenced code without changing its text or interpreting it as HTML" do
    source = ~s(def greet, do: "<b>Fry</b> & café")
    html = Code.summary_markdown_html("```elixir\n#{source}\n```\n\n```text\n#{source}\n```")

    blocks = html |> Floki.parse_document!() |> Floki.find("pre code")

    text_blocks =
      html
      |> String.replace(~r/<\/?span\b[^>]*>/u, "")
      |> Floki.parse_document!()
      |> Floki.find("pre code")

    assert length(blocks) == 2
    assert Enum.all?(text_blocks, &(String.trim(Floki.text(&1)) == source))
    assert Floki.find(hd(blocks), ".tok-keyword") != []
    assert Floki.find(List.last(blocks), "span") == []
    assert Floki.find(blocks, "b") == []
  end
end
