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
  end

  test "table renders slots" do
    html =
      render_component(&DataDisplay.table/1, %{
        inner_block: TestHelpers.slot("<tbody></tbody>")
      })

    assert html =~ "data-slot=\"table\""
  end
end
