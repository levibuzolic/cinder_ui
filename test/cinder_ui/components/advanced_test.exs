defmodule CinderUI.Components.AdvancedTest.ComboboxProbe do
  use Phoenix.Component

  import CinderUI.Components.Advanced.Command, only: [combobox: 1]

  def render(assigns) do
    ~H"""
    <.combobox id="framework-combobox" open={true}>
      <:option value="next" label="Next.js">
        <span data-slot="probe-custom-framework">
          <strong>Next.js</strong>
          <span>React framework</span>
        </span>
      </:option>
    </.combobox>
    """
  end
end

defmodule CinderUI.Components.AdvancedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Advanced
  alias CinderUI.Components.AdvancedTest.ComboboxProbe
  alias CinderUI.TestHelpers
  alias Phoenix.HTML

  test "command renders groups" do
    html =
      render_component(&Advanced.command/1, %{
        group: [
          %{heading: "Main", inner_block: fn _, _ -> "Items" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='command']", "data-slot") == "command"
    assert TestHelpers.text(html, "[data-slot='command-group-heading']") == "Main"
    assert TestHelpers.text(html, "[data-slot='command-group']") == "Main Items"
  end

  test "carousel renders aria semantics, controls, and indicators" do
    html =
      render_component(&Advanced.carousel/1, %{
        id: "feature-carousel",
        autoplay: 4000,
        indicators: true,
        item: [
          %{inner_block: fn _, _ -> "Slide one" end},
          %{inner_block: fn _, _ -> "Slide two" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='carousel']", "data-autoplay") == "4000"
    assert TestHelpers.attr(html, "[data-slot='carousel']", "aria-roledescription") == "carousel"
    assert TestHelpers.find_all(html, "[data-slot='carousel-item']") |> length() == 2

    assert TestHelpers.attr(html, "[data-slot='carousel-item']", "aria-roledescription") ==
             "slide"

    assert TestHelpers.attr(html, "[data-slot='carousel-previous']", "aria-label") ==
             "Previous slide"

    assert TestHelpers.attr(html, "[data-slot='carousel-next']", "aria-label") == "Next slide"
    assert TestHelpers.find_all(html, "[data-slot='carousel-indicator']") |> length() == 2

    assert TestHelpers.attr(html, "[data-slot='carousel-indicator']", "aria-label") ==
             "Go to slide 1"

    assert TestHelpers.text(html, "[data-slot='carousel-content']") == "Slide one Slide two"
  end

  test "sidebar layout renders panel and main regions with sidebar tokens" do
    layout_html =
      render_component(&Advanced.sidebar_layout/1, %{
        id: "shell",
        header: [%{inner_block: fn _, _ -> "Header" end}],
        sidebar: [%{inner_block: fn _, _ -> "Overview" end}],
        footer: [%{inner_block: fn _, _ -> "Footer" end}],
        main: [
          %{
            class: "px-8",
            inner_block: fn _, _ -> "Main content" end
          }
        ]
      })

    assert TestHelpers.attr(layout_html, "[data-slot='sidebar-layout']", "id") == "shell"

    assert TestHelpers.text(layout_html, "[data-slot='sidebar-panel']") ==
             "Header Overview Footer"

    assert TestHelpers.text(layout_html, "[data-slot='sidebar-main']") == "Main content"
    assert TestHelpers.has_class?(layout_html, "[data-slot='sidebar-panel']", "bg-sidebar")

    assert TestHelpers.has_class?(
             layout_html,
             "[data-slot='sidebar-panel']",
             "text-sidebar-foreground"
           )

    assert TestHelpers.has_class?(
             layout_html,
             "[data-slot='sidebar-panel']",
             "border-sidebar-border"
           )

    assert TestHelpers.has_class?(layout_html, "[data-slot='sidebar-main']", "px-8")
  end

  test "combobox renders hook-backed input and items" do
    html =
      render_component(&Advanced.combobox/1, %{
        id: "plan-combobox",
        value: "Pro",
        open: true,
        content_class: "min-w-48",
        option: [
          %{value: "Free", label: "Free", inner_block: fn -> "" end},
          %{value: "Pro", label: "Pro", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='combobox']", "phx-hook") == "CuiCombobox"
    assert TestHelpers.attr(html, "[data-slot='combobox']", "data-state") == "open"
    assert TestHelpers.attr(html, "[data-slot='combobox-input']", "value") == "Pro"
    assert TestHelpers.has_class?(html, "[data-slot='combobox-content']", "block")
    refute TestHelpers.has_class?(html, "[data-slot='combobox-content']", "hidden")
    assert TestHelpers.has_class?(html, "[data-slot='combobox-content']", "min-w-48")
    assert TestHelpers.find_all(html, "[data-slot='combobox-item']") |> length() == 2
    assert TestHelpers.find_all(html, "[data-slot='select-check']") |> length() == 2
    refute TestHelpers.has_class?(html, "[data-slot='combobox-group']", "py-1")
  end

  test "combobox supports grouped and custom option content" do
    html =
      render_component(&Advanced.combobox/1, %{
        id: "framework-combobox",
        value: "Next.js",
        option: [
          %{
            value: "next",
            label: "Next.js",
            group: "Frontend",
            inner_block: fn _, _ ->
              HTML.raw("""
              <span data-slot="custom-framework">
                <strong>Next.js</strong>
                <span>React framework</span>
              </span>
              """)
            end
          },
          %{
            value: "phoenix",
            label: "Phoenix",
            group: "Backend",
            inner_block: fn -> "" end
          }
        ]
      })

    assert TestHelpers.find_all(html, "[data-slot='combobox-group']") |> length() == 2
    assert TestHelpers.has_class?(html, "[data-slot='combobox-group']", "py-1")
    assert TestHelpers.text(html, "[data-slot='combobox-group-label']") == "Frontend"
    assert TestHelpers.text(html, "[data-slot='custom-framework']") == "Next.js React framework"

    assert TestHelpers.attr(html, "[data-slot='combobox-item'][data-value='next']", "data-label") ==
             "Next.js"

    assert TestHelpers.attr(
             html,
             "[data-slot='combobox-item'][data-value='next']",
             "data-selected"
           ) ==
             "true"
  end

  test "combobox renders custom option bodies from HEEx slots" do
    html = render_component(&ComboboxProbe.render/1, %{})

    assert TestHelpers.text(html, "[data-slot='probe-custom-framework']") ==
             "Next.js React framework"
  end

  test "chart renders title, description, and content shell" do
    html =
      render_component(&Advanced.chart/1, %{
        title: [%{inner_block: fn _, _ -> "Traffic" end}],
        description: [%{inner_block: fn _, _ -> "Last 7 days" end}],
        inner_block: [%{inner_block: fn _, _ -> HTML.raw("<div>Chart body</div>") end}]
      })

    assert TestHelpers.attr(html, "[data-slot='chart']", "data-slot") == "chart"
    assert TestHelpers.text(html, "header h3") == "Traffic"
    assert TestHelpers.text(html, "header p") == "Last 7 days"
    assert TestHelpers.text(html, "[data-slot='chart-content']") == "Chart body"
  end

  test "sidebar_profile_menu renders LiveView links and disabled actions" do
    html =
      render_component(&Advanced.sidebar_profile_menu/1, %{
        id: "account-menu",
        name: "Levi Buzolic",
        subtitle: "levi@example.com",
        item: [
          %{navigate: "/settings", icon: "settings", inner_block: fn _, _ -> "Settings" end},
          %{disabled: true, icon: "log-out", inner_block: fn _, _ -> "Log out" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='sidebar-profile-menu']", "phx-hook") ==
             "CuiDropdownMenu"

    assert TestHelpers.attr(html, "a[data-slot='dropdown-menu-item']", "href") == "/settings"

    assert TestHelpers.attr(html, "a[data-slot='dropdown-menu-item']", "data-phx-link") ==
             "redirect"

    assert TestHelpers.attr(
             html,
             "button[data-slot='dropdown-menu-item'][disabled]",
             "disabled"
           ) == "disabled"
  end
end
