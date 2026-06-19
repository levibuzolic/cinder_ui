defmodule CinderUI.Docs.UIComponents.CodeTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.UIComponents.Code

  test "renders markdown summaries through ExDoc markdown" do
    html = Code.summary_markdown_html("Use `button/1` with [Phoenix](https://phoenixframework.org).")

    assert html =~ ~s(<code class="inline">button/1</code>)
    assert html =~ ~s(<a href="https://phoenixframework.org">Phoenix</a>)
  end
end
