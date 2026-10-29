defmodule CinderUI.Docs.InlineExamplesTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.InlineExamples

  test "removes the Markdown indent once, preserving nested code indentation" do
    [example] =
      InlineExamples.parse("""
      ## Example

          <.field>
              <.input name="owner" />
          </.field>
      """)

    assert example.template_heex == "<.field>\n    <.input name=\"owner\" />\n</.field>"
  end
end
