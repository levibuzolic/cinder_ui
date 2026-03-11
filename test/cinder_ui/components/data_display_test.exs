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

  test "table renders slots" do
    html =
      render_component(&DataDisplay.table/1, %{
        inner_block: TestHelpers.slot("<tbody></tbody>")
      })

    assert html =~ "data-slot=\"table\""
  end
end
