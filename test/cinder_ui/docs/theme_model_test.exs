defmodule CinderUI.Docs.ThemeModelTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.ThemeModel

  test "theme model owns docs defaults, storage keys, and options" do
    model = ThemeModel.model()

    assert model["storage"] == %{
             "mode" => "cui:theme:mode",
             "color" => "cui:theme:color",
             "radius" => "cui:theme:radius"
           }

    assert model["defaults"] == %{"mode" => "auto", "color" => "neutral", "radius" => "nova"}
    assert Enum.map(model["modes"], & &1["value"]) == ["light", "dark", "auto"]

    assert Enum.sort(Enum.map(ThemeModel.color_options(), & &1.value)) ==
             Enum.sort(Map.keys(model["palettes"]))

    assert Enum.find(ThemeModel.radius_options(), &(&1.value == "vega")).label ==
             "XL (16px / 1rem)"
  end

  test "generated bootstrap and static docs scripts embed the canonical model" do
    bootstrap = ThemeModel.bootstrap_script()
    static_docs = ThemeModel.static_docs_js("window.__themeTest = true")

    assert bootstrap =~ "globalThis.CinderUIThemeModel ="
    assert bootstrap =~ "globalThis.CinderUITheme.applyStoredTheme"
    assert bootstrap =~ ~s("color": "neutral")
    assert static_docs =~ "globalThis.CinderUIThemeModel ="
    assert static_docs =~ "window.__themeTest = true"
  end
end
