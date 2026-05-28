defmodule CinderUI.GeneratedAssetsSupport do
  @moduledoc false

  @root Path.expand("../..", __DIR__)
  @generated_demo_assets [
    {"priv/templates/cinder_ui.css", "demo/assets/css/cinder_ui.css"}
  ]

  def ensure_demo_assets! do
    Enum.each(@generated_demo_assets, fn {source, target} ->
      source_path = Path.join(@root, source)
      target_path = Path.join(@root, target)

      File.mkdir_p!(Path.dirname(target_path))
      File.write!(target_path, File.read!(source_path))
    end)

    js_target_path = Path.join(@root, "demo/assets/js/cinder_ui.js")

    File.mkdir_p!(Path.dirname(js_target_path))
    File.write!(js_target_path, CinderUI.Assets.cinder_ui_js())
  end
end
