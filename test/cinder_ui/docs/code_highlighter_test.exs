defmodule CinderUI.Docs.CodeHighlighterTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.CodeHighlighter

  test "preserves HEEx attribute order in tags" do
    source = ~s(<.button type="submit">Save changes</.button>)

    highlighted = CodeHighlighter.highlight(source, :heex)

    assert highlighted =~
             ~s(<span class="tok-punct">&lt;</span><span class="tok-tag">.button</span> <span class="tok-attr">type</span><span class="tok-operator">=</span><span class="tok-string">&quot;submit&quot;</span><span class="tok-punct">&gt;</span>)

    refute highlighted =~
             ~s(&quot;submit&quot;</span><span class="tok-operator">=</span><span class="tok-attr">type</span>)
  end

  test "preserves valid UTF-8 outside quoted strings in every code tokenizer" do
    for language <- [:elixir, :css, :bash] do
      highlighted = CodeHighlighter.highlight("café ☕", language)

      assert String.valid?(highlighted)
      assert highlighted |> String.replace(~r/<[^>]+>/, "") == "café ☕"
    end
  end
end
