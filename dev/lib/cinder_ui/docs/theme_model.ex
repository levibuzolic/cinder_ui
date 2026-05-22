defmodule CinderUI.Docs.ThemeModel do
  @moduledoc false

  @model_path Path.expand("../../../assets/docs/theme_model.json", __DIR__)
  @runtime_path Path.expand("../../../../priv/site_templates/theme_bootstrap.js", __DIR__)

  @external_resource @model_path
  @external_resource @runtime_path

  @model_json File.read!(@model_path)
  @model Jason.decode!(@model_json)

  def model, do: @model

  def model_json, do: @model_json

  def color_options, do: option_maps("colors")

  def radius_options, do: option_maps("radii")

  def runtime_js do
    model_assignment_js() <> File.read!(@runtime_path)
  end

  def bootstrap_js do
    runtime_js() <> "\nglobalThis.CinderUITheme.applyStoredTheme({ syncControls: false });\n"
  end

  def bootstrap_script do
    "<script>\n#{bootstrap_js()}</script>"
  end

  def static_docs_js(static_docs_source) when is_binary(static_docs_source) do
    runtime_js() <> "\n" <> static_docs_source <> ";\n"
  end

  defp model_assignment_js do
    "globalThis.CinderUIThemeModel = #{@model_json};\n"
  end

  defp option_maps(key) do
    @model
    |> Map.fetch!(key)
    |> Enum.map(fn option ->
      %{value: Map.fetch!(option, "value"), label: Map.fetch!(option, "label")}
    end)
  end
end
