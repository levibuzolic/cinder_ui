defmodule CinderUI.RegistryTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Registry
  alias CinderUI.TestHelpers

  defmodule ImportProbe do
    use Phoenix.Component
    use CinderUI

    def render(assigns) do
      ~H"""
      <.button>Save</.button>
      """
    end
  end

  test "sections are the canonical component module source" do
    sections = Registry.sections()

    assert Enum.map(sections, & &1.id) == [
             "actions",
             "forms",
             "layout",
             "icons",
             "feedback",
             "data-display",
             "navigation",
             "overlay",
             "advanced"
           ]

    assert Registry.modules() == Enum.map(sections, & &1.module)
    assert Registry.section_for_module(CinderUI.Components.Forms).id == "forms"
  end

  test "functions expose all public component functions" do
    functions = Registry.functions()

    assert {CinderUI.Components.Actions, :button} in functions
    assert {CinderUI.Components.Forms, :input} in functions
    assert {CinderUI.Icons, :icon} in functions

    refute Enum.any?(functions, fn {_module, function} ->
             String.starts_with?(to_string(function), "__")
           end)

    component_modules = Registry.component_modules()

    assert component_modules.button == CinderUI.Components.Actions
    assert component_modules.input == CinderUI.Components.Forms
    assert component_modules.icon == CinderUI.Icons
  end

  test "runtime metadata is shared by docs and public registry consumers" do
    assert Registry.runtime(CinderUI.Components.Forms, :select).kind == :progressive
    assert Registry.runtime(CinderUI.Components.Navigation, :navigation_menu).kind == :scaffold
    assert Registry.runtime(CinderUI.Components.Actions, :button).kind == :server
  end

  test "public facades render through registry-backed component ownership" do
    ui_html = render_component(&CinderUI.UI.button/1, %{inner_block: TestHelpers.slot("Save")})
    imported_html = render_component(&ImportProbe.render/1, %{})

    assert TestHelpers.text(ui_html, "[data-slot='button']") == "Save"
    assert TestHelpers.text(imported_html, "[data-slot='button']") == "Save"
  end
end
