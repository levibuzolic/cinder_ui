defmodule CinderUI.ThemeCSSTest do
  use ExUnit.Case, async: true

  @css_path Path.expand("../../priv/templates/cinder_ui.css", __DIR__)
  @docs_theme_path Path.expand("../../dev/assets/docs/theme.css", __DIR__)
  @demo_mix_path Path.expand("../../demo/mix.exs", __DIR__)
  @demo_app_css_path Path.expand("../../demo/assets/css/app.css", __DIR__)

  test "theme CSS opts native form controls into the active color scheme" do
    css = File.read!(@css_path)

    assert css =~ ~r/:root\s*\{[^}]*color-scheme:\s*light;/s

    assert css =~
             ~r/:root\.dark,\s*:root\[data-theme="dark"\],\s*\[data-theme="dark"\]\s*\{[^}]*color-scheme:\s*dark;/s

    assert css =~
             ~r/:root:not\(\.dark\):not\(\[data-theme="dark"\]\):not\(\[data-theme="light"\]\):not\(\[data-theme-mode="light"\]\)\s*\{[^}]*color-scheme:\s*dark;/s
  end

  test "docs theme imports the packaged CSS template as its source of truth" do
    docs_theme = File.read!(@docs_theme_path)

    assert docs_theme
           |> String.split("\n", parts: 2)
           |> hd() == ~s(@import "../../../priv/templates/cinder_ui.css";)
  end

  test "Hex package includes the CSS template consumed by the install task" do
    package_files =
      Mix.Project.config()
      |> Keyword.fetch!(:package)
      |> Keyword.fetch!(:files)

    assert "priv" in package_files
  end

  test "demo asset build regenerates its generated CSS copy" do
    demo_mix = File.read!(@demo_mix_path)
    demo_app_css = File.read!(@demo_app_css_path)

    assert demo_mix =~ ~s("cinder_ui.install --assets-path assets --skip-patching")
    assert demo_app_css =~ ~s(@import "./cinder_ui.css";)
  end
end
