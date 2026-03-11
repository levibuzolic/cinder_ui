defmodule CinderUI.Docs.CodeHighlighterTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.CodeHighlighter

  test "highlights HEEx inside Elixir ~H heredocs" do
    source = """
    def render(assigns) do
      ~H\"\"\"
      <.button variant={:outline}>
        {@label}
      </.button>
      \"\"\"
    end
    """

    highlighted = CodeHighlighter.highlight(source, :elixir)

    assert highlighted =~ ~s(<span class="tok-keyword">def</span>)

    assert highlighted =~
             ~s(<span class="tok-keyword">~H</span><span class="tok-string">&quot;&quot;&quot;</span>)

    assert highlighted =~ ~s(<span class="tok-tag">.button</span>)
    assert highlighted =~ ~s(<span class="tok-attr">variant</span>)
    assert highlighted =~ ~s(<span class="tok-atom">:outline</span>)

    assert highlighted =~
             ~s(<span class="tok-expr"><span class="tok-punct">{</span>@<span class="tok-ident">label</span><span class="tok-punct">}</span></span>)

    assert highlighted =~ ~s(<span class="tok-string">&quot;&quot;&quot;</span>)
  end

  test "keeps ordinary Elixir heredocs grouped as strings" do
    source = """
    css = \"\"\"
    .button {
      color: red;
    }
    \"\"\"
    """

    highlighted = CodeHighlighter.highlight(source, :elixir)

    assert highlighted =~ ~s(<span class="tok-ident">css</span>)

    assert highlighted =~
             ~s(<span class="tok-string">&quot;&quot;&quot;\n.button {\n  color: red;\n}\n&quot;&quot;&quot;</span>)
  end

  test "preserves HEEx attribute order in tags" do
    source = ~s(<.button type="submit">Save changes</.button>)

    highlighted = CodeHighlighter.highlight(source, :heex)

    assert highlighted =~
             ~s(<span class="tok-punct">&lt;</span><span class="tok-tag">.button</span> <span class="tok-attr">type</span><span class="tok-operator">=</span><span class="tok-string">&quot;submit&quot;</span><span class="tok-punct">&gt;</span>)

    refute highlighted =~
             ~s(&quot;submit&quot;</span><span class="tok-operator">=</span><span class="tok-attr">type</span>)
  end
end
