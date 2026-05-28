defmodule CinderUI.Components.FieldFamilyTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.FieldFamily
  alias CinderUI.TestHelpers

  test "field family structural components render semantic wrappers" do
    field_set_html =
      render_component(&FieldFamily.field_set/1, %{
        inner_block: TestHelpers.slot("Billing")
      })

    field_group_html =
      render_component(&FieldFamily.field_group/1, %{
        inner_block: TestHelpers.slot("Fields")
      })

    legend_html =
      render_component(&FieldFamily.field_legend/1, %{
        variant: :label,
        inner_block: TestHelpers.slot("Preferences")
      })

    content_html =
      render_component(&FieldFamily.field_content/1, %{
        inner_block: TestHelpers.slot("Content")
      })

    title_html =
      render_component(&FieldFamily.field_title/1, %{
        inner_block: TestHelpers.slot("Title")
      })

    assert TestHelpers.text(field_set_html, "[data-slot='field-set']") == "Billing"
    assert TestHelpers.has_class?(field_set_html, "[data-slot='field-set']", "gap-6")

    assert TestHelpers.text(field_group_html, "[data-slot='field-group']") == "Fields"
    assert TestHelpers.has_class?(field_group_html, "[data-slot='field-group']", "gap-6")

    assert TestHelpers.attr(legend_html, "[data-slot='field-legend']", "data-variant") == "label"
    assert TestHelpers.has_class?(legend_html, "[data-slot='field-legend']", "text-sm")

    assert TestHelpers.text(content_html, "[data-slot='field-content']") == "Content"
    assert TestHelpers.has_class?(content_html, "[data-slot='field-content']", "flex-1")

    assert TestHelpers.text(title_html, "[data-slot='field-title']") == "Title"
    assert TestHelpers.has_class?(title_html, "[data-slot='field-title']", "font-medium")
  end

  test "field_separator renders plain and labeled dividers" do
    plain_html = render_component(&FieldFamily.field_separator/1, %{})

    labeled_html =
      render_component(&FieldFamily.field_separator/1, %{
        inner_block: TestHelpers.slot("Tasks")
      })

    assert TestHelpers.attr(plain_html, "[data-slot='field-separator']", "role") == "separator"
    assert TestHelpers.has_class?(plain_html, "[data-slot='field-separator']", "h-px")

    assert TestHelpers.text(labeled_html, "[data-slot='field-separator']") == "Tasks"

    assert TestHelpers.find_all(labeled_html, "[data-slot='field-separator'] [role='separator']")
           |> length() == 2
  end
end
