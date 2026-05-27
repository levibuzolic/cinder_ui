defmodule CinderUI.Docs.UIComponents do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Docs.UIComponents.Catalog
  alias CinderUI.Docs.UIComponents.Code
  alias CinderUI.Docs.UIComponents.Shell

  defdelegate recipes_page(assigns), to: CinderUI.Docs.Recipes

  defdelegate docs_external_link_button(assigns), to: Shell
  defdelegate theme_mode_toggle(assigns), to: Shell
  defdelegate docs_layout(assigns), to: Shell
  defdelegate docs_header_links(assigns), to: Shell
  defdelegate docs_sidebar(assigns), to: Shell
  defdelegate docs_theme_controls(assigns), to: Shell
  defdelegate docs_search_button(assigns), to: Shell

  defdelegate docs_code_block(assigns), to: Code
  defdelegate summary_markdown_html(text), to: Code

  defdelegate docs_overview_intro(assigns), to: Catalog
  defdelegate docs_overview_sections(assigns), to: Catalog
  defdelegate docs_component_detail(assigns), to: Catalog
end
