defmodule CinderUI.Components.OverlayTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Overlay
  alias CinderUI.TestHelpers

  test "dialog renders trigger, content, and aria relationships" do
    html =
      render_component(&Overlay.dialog/1, %{
        id: "demo-dialog",
        open: true,
        trigger: [%{inner_block: fn _, _ -> "Open" end}],
        title: [%{inner_block: fn _, _ -> "Title" end}],
        description: [%{inner_block: fn _, _ -> "Desc" end}],
        footer: [%{inner_block: fn _, _ -> "Footer" end}],
        inner_block: TestHelpers.slot("Body")
      })

    assert html =~ "data-slot=\"dialog\""
    assert html =~ "Open"
    assert html =~ "Body"
    assert html =~ ~s(aria-labelledby="demo-dialog-title")
    assert html =~ ~s(aria-describedby="demo-dialog-description")
    assert html =~ ~s(id="demo-dialog-title")
    assert html =~ ~s(id="demo-dialog-description")
  end

  test "dropdown menu renders items" do
    html =
      render_component(&Overlay.dropdown_menu/1, %{
        id: "demo-dropdown",
        trigger: [%{inner_block: fn _, _ -> "Open" end}],
        item: [
          %{href: "/settings", disabled: false, inner_block: fn _, _ -> "Settings" end},
          %{disabled: true, inner_block: fn _, _ -> "Archive" end}
        ]
      })

    assert html =~ "data-slot=\"dropdown-menu\""
    assert html =~ ~s(role="menu")
    assert html =~ ~s(role="menuitem")
    assert html =~ "Settings"
    assert html =~ "Archive"
    assert html =~ "disabled"
    refute html =~ "pointer-events-none opacity-50"
  end

  test "drawer and sheet render distinct slots" do
    drawer_html =
      render_component(&Overlay.drawer/1, %{
        id: "demo-drawer",
        open: true,
        trigger: [%{inner_block: fn _, _ -> "Open drawer" end}],
        title: [%{inner_block: fn _, _ -> "Drawer" end}],
        description: [%{inner_block: fn _, _ -> "Drawer desc" end}],
        inner_block: TestHelpers.slot("Drawer body")
      })

    sheet_html =
      render_component(&Overlay.sheet/1, %{
        id: "demo-sheet",
        open: true,
        side: :right,
        trigger: [%{inner_block: fn _, _ -> "Open sheet" end}],
        title: [%{inner_block: fn _, _ -> "Sheet" end}],
        description: [%{inner_block: fn _, _ -> "Sheet desc" end}],
        inner_block: TestHelpers.slot("Sheet body")
      })

    assert drawer_html =~ "data-slot=\"drawer\""
    assert drawer_html =~ "data-drawer-side=\"bottom\""
    assert drawer_html =~ ~s(aria-labelledby="demo-drawer-title")
    assert drawer_html =~ ~s(aria-describedby="demo-drawer-description")
    assert sheet_html =~ "data-slot=\"sheet\""
    assert sheet_html =~ "data-sheet-side=\"right\""
    assert sheet_html =~ ~s(aria-labelledby="demo-sheet-title")
    assert sheet_html =~ ~s(aria-describedby="demo-sheet-description")
  end
end
