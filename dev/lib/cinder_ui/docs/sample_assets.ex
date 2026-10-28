defmodule CinderUI.Docs.SampleAssets do
  @moduledoc false

  alias CinderUI.Docs.SampleData

  def hydrate_template_for_preview(snippet, _module, _function) do
    Enum.reduce(SampleData.characters(), snippet, fn character, template ->
      Regex.replace(
        ~r/(src=["'])example\.png(["']\s+(?:avatar_)?alt=["']#{Regex.escape(character.label)}["'])/u,
        template,
        fn _full, prefix, suffix -> prefix <> character.avatar <> suffix end
      )
    end)
  end
end
