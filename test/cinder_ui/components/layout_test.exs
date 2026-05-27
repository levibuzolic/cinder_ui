defmodule CinderUI.Components.LayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Layout
  alias CinderUI.TestHelpers

  test "card renders slots" do
    html = render_component(&Layout.card/1, %{inner_block: TestHelpers.slot("Body")})
    assert html =~ "data-slot=\"card\""
    assert html =~ "Body"
  end

  test "separator handles orientation" do
    html = render_component(&Layout.separator/1, %{orientation: :vertical})
    assert html =~ "data-orientation=\"vertical\""
  end

  test "typography renders semantic variant defaults" do
    html =
      render_component(&Layout.typography/1, %{
        variant: :h2,
        inner_block: TestHelpers.slot("Revenue overview")
      })

    assert html =~ "<h2"
    assert html =~ "data-slot=\"typography\""
    assert html =~ "data-variant=\"h2\""
    assert html =~ "Revenue overview"
    assert html =~ "text-3xl"
  end

  test "typography supports tag overrides" do
    html =
      render_component(&Layout.typography/1, %{
        variant: :small,
        as: "p",
        inner_block: TestHelpers.slot("Updated just now")
      })

    assert html =~ "<p"
    assert html =~ "data-variant=\"small\""
    assert html =~ "text-sm"
    refute html =~ "<small"
  end

  test "resizable renders hook, handles, and optional storage key" do
    html =
      render_component(&Layout.resizable/1, %{
        direction: :horizontal,
        with_handle: true,
        storage_key: "layout-main",
        panel: [
          %{size: 40, min_size: 20, inner_block: fn _, _ -> "Left" end},
          %{size: 60, min_size: 30, inner_block: fn _, _ -> "Right" end}
        ]
      })

    assert html =~ "phx-hook=\"CuiResizable\""
    assert html =~ "data-storage-key=\"layout-main\""
    assert html =~ "data-slot=\"resizable-handle\""
    assert html =~ "data-with-handle"
    assert html =~ "data-min-size=\"20\""
    assert html =~ "data-min-size=\"30\""
  end
end
