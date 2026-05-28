defmodule CinderUI.Assets do
  @moduledoc false

  @priv_dir Path.expand("../../priv", __DIR__)
  @template_dir Path.join(@priv_dir, "templates")
  @js_source_dir Path.join(@template_dir, "cinder_ui")

  @js_sources [
    "constants.js",
    "dom.js",
    "commands.js",
    "focus.js",
    "inert.js",
    "hooks/dialog.js",
    "hooks/panels.js",
    "hooks/popover.js",
    "hooks/dropdown_menu.js",
    "hooks/menubar.js",
    "hooks/select.js",
    "hooks/autocomplete.js",
    "hooks/input_otp.js",
    "hooks/code_block.js",
    "hooks/combobox.js",
    "hooks/sidebar.js",
    "hooks/carousel.js",
    "hooks/resizable.js",
    "index.js"
  ]

  def cinder_ui_css do
    @template_dir
    |> Path.join("cinder_ui.css")
    |> File.read!()
  end

  def cinder_ui_js do
    body =
      @js_sources
      |> Enum.map_join("\n\n", &read_js_source!/1)

    """
    // This file is generated from priv/templates/cinder_ui/.
    // Do not edit it directly; edit the modular sources instead.

    #{body}
    """
  end

  defp read_js_source!(source) do
    @js_source_dir
    |> Path.join(source)
    |> File.read!()
    |> String.trim_trailing()
    |> strip_imports()
    |> remove_internal_exports()
  end

  defp strip_imports(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&String.starts_with?(&1, "import "))
    |> Enum.join("\n")
  end

  defp remove_internal_exports(content) do
    Regex.replace(~r/^export const (?!CinderUIHooks\b|CinderUI\b)/m, content, "const ")
  end
end
