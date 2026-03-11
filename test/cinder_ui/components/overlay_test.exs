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

  test "tooltip links trigger and content with aria-describedby" do
    html =
      render_component(&Overlay.tooltip/1, %{
        text: "Copy API key",
        inner_block: TestHelpers.slot("Copy")
      })

    assert html =~ "data-slot=\"tooltip\""
    assert html =~ "data-slot=\"tooltip-trigger\""
    assert html =~ "data-slot=\"tooltip-content\""
    assert html =~ ~s(role="tooltip")

    [_, tooltip_id] = Regex.run(~r/aria-describedby="([^"]+)"/, html)
    assert html =~ ~s(id="#{tooltip_id}")
  end

  test "hover card supports focus-within visibility class" do
    html =
      render_component(&Overlay.hover_card/1, %{
        trigger: [%{inner_block: fn _, _ -> "Levi" end}],
        content: [%{inner_block: fn _, _ -> "Maintains docs" end}]
      })

    assert html =~ "data-slot=\"hover-card\""
    assert html =~ "group-hover:block"
    assert html =~ "group-focus-within:block"
  end

  test "menubar renders hook-enabled triggers and menus" do
    html =
      render_component(&Overlay.menubar/1, %{
        id: "app-menubar",
        menu: [
          %{label: "File", inner_block: fn _, _ -> "New project" end},
          %{label: "View", inner_block: fn _, _ -> "Toggle sidebar" end}
        ]
      })

    assert html =~ "data-slot=\"menubar\""
    assert html =~ "phx-hook=\"CuiMenubar\""
    assert html =~ ~s(role="menubar")
    assert html =~ "data-menubar-trigger"
    assert html =~ "data-menubar-content"
    assert html =~ ~s(aria-controls="app-menubar-menu-0")
    assert html =~ ~s(role="menu")
  end

  test "menubar generates an id when omitted" do
    html =
      render_component(&Overlay.menubar/1, %{
        menu: [
          %{label: "File", inner_block: fn _, _ -> "New project" end}
        ]
      })

    assert html =~ ~r/id="cinder-ui-menubar-\d+"/
    assert html =~ ~r/aria-controls="cinder-ui-menubar-\d+-menu-0"/
  end

  test "popover renders trigger and hook-backed content" do
    html =
      render_component(&Overlay.popover/1, %{
        id: "share-popover",
        trigger: [%{inner_block: fn _, _ -> "Share" end}],
        content: [%{inner_block: fn _, _ -> "Copy link" end}]
      })

    assert html =~ "data-slot=\"popover\""
    assert html =~ "phx-hook=\"CuiPopover\""
    assert html =~ "data-slot=\"popover-trigger\""
    assert html =~ "data-slot=\"popover-content\""
  end

  test "alert_dialog delegates to dialog structure with destructive styling" do
    html =
      render_component(&Overlay.alert_dialog/1, %{
        id: "delete-dialog",
        open: true,
        trigger: [%{inner_block: fn _, _ -> "Delete" end}],
        title: [%{inner_block: fn _, _ -> "Delete project?" end}],
        description: [%{inner_block: fn _, _ -> "This cannot be undone." end}],
        footer: [%{inner_block: fn _, _ -> "Footer" end}],
        inner_block: TestHelpers.slot("Body")
      })

    assert html =~ "data-slot=\"dialog\""
    assert html =~ "data-slot=\"dialog-content\""
    assert html =~ "ring-destructive/20"
    assert html =~ "Delete project?"
  end
end
