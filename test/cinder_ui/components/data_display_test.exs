defmodule CinderUI.Components.DataDisplayTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.DataDisplay
  alias CinderUI.TestHelpers

  test "avatar renders fallback" do
    html = render_component(&DataDisplay.avatar/1, %{alt: "Philip J. Fry"})
    assert html =~ "data-slot=\"avatar\""
    assert html =~ "PJ"
  end

  test "avatar image hides on error and reveals fallback" do
    html =
      render_component(&DataDisplay.avatar/1, %{
        src: "/missing.png",
        alt: "Philip J. Fry"
      })

    assert html =~ "data-slot=\"avatar-image\""
    assert html =~ "onerror="
    assert html =~ "data-slot=\"avatar-fallback\""
    assert html =~ "hidden"
    assert html =~ "PJ"
  end

  test "avatar_group_count supports size variants" do
    html =
      render_component(&DataDisplay.avatar_group_count/1, %{
        size: :sm,
        inner_block: TestHelpers.slot("+3")
      })

    assert html =~ "data-slot=\"avatar-group-count\""
    assert html =~ "data-size=\"sm\""
    assert html =~ "size-6"
    assert html =~ "+3"
  end

  test "avatar_group renders overlap classes" do
    html =
      render_component(&DataDisplay.avatar_group/1, %{
        inner_block: TestHelpers.slot("Avatars")
      })

    assert html =~ "data-slot=\"avatar-group\""
    assert html =~ "-space-x-2"
    assert html =~ "*:data-[slot=avatar]:ring-2"
  end

  test "accordion renders item structure and open state" do
    html =
      render_component(&DataDisplay.accordion/1, %{
        item: [
          %{title: "Item 1", open: true, inner_block: fn _, _ -> "Content 1" end},
          %{title: "Item 2", inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    assert html =~ "data-slot=\"accordion\""
    assert html =~ "data-slot=\"accordion-item\""
    assert html =~ "data-slot=\"accordion-trigger\""
    assert html =~ "data-slot=\"accordion-content\""
    assert html =~ "open"
  end

  test "collapsible renders trigger and content" do
    html =
      render_component(&DataDisplay.collapsible/1, %{
        open: true,
        trigger: [%{inner_block: fn _, _ -> "Release notes" end}],
        inner_block: TestHelpers.slot("Added examples")
      })

    assert html =~ "data-slot=\"collapsible\""
    assert html =~ "data-slot=\"collapsible-trigger\""
    assert html =~ "data-slot=\"collapsible-content\""
    assert html =~ "Release notes"
  end

  test "code_block renders copy button and hook" do
    html =
      render_component(&DataDisplay.code_block/1, %{
        inner_block: TestHelpers.slot("mix test")
      })

    assert html =~ "data-slot=\"code-block\""
    assert html =~ "phx-hook=\"CuiCodeBlock\""
    assert html =~ "data-slot=\"code-block-copy\""
    assert html =~ "data-code-block-content"
    assert html =~ "Copy"
    assert html =~ ~r/id="cinder-ui-code-block-\d+"/
  end

  test "table renders slots" do
    html =
      render_component(&DataDisplay.table/1, %{
        inner_block: TestHelpers.slot("<tbody></tbody>")
      })

    assert html =~ "data-slot=\"table\""
  end
end
