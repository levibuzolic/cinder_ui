defmodule Demo.SiteRuntime do
  @moduledoc false

  alias CinderUI.Assets
  alias CinderUI.Docs.Catalog
  alias CinderUI.Docs.ThemeModel

  @repo_root Path.expand("../../..", __DIR__)
  @docs_assets_dir Path.join(@repo_root, "dev/assets/docs")
  @site_assets_dir Path.join(@repo_root, "dev/assets/site")
  @theme_css_fallback Path.expand("../../priv/static/assets/css/app.css", __DIR__)
  @github_url "https://github.com/levibuzolic/cinder_ui"
  @hex_package_url "https://hex.pm/packages/cinder_ui"

  @catalog_count_key {__MODULE__, :catalog_count}

  def asset_path(path) when is_binary(path) do
    case path do
      "static_docs.js" -> Path.join(@docs_assets_dir, "static_docs.js")
      "site.css" -> Path.join(@site_assets_dir, "site.css")
      "theme.css" -> theme_css_path()
      _ -> nil
    end
  end

  def docs_site_js do
    ThemeModel.static_docs_js(asset!("static_docs.js"))
  end

  def cinder_ui_js do
    Assets.cinder_ui_js()
  end

  def catalog_sections do
    Enum.map(Catalog.section_definitions(), &cached_section/1)
  end

  def catalog_component_count do
    case :persistent_term.get(@catalog_count_key, :missing) do
      :missing ->
        count = catalog_sections() |> Enum.flat_map(& &1.entries) |> length()
        :persistent_term.put(@catalog_count_key, count)
        count

      count ->
        count
    end
  end

  def find_entry(id) when is_binary(id) do
    catalog_sections()
    |> Enum.find_value(fn section -> Enum.find(section.entries, &(&1.id == id)) end)
  end

  def static_paths do
    sections = catalog_sections()

    ["/", "/docs/", "/docs/install/"] ++
      Enum.map(Enum.flat_map(sections, & &1.entries), fn entry ->
        "/docs/#{entry.id}/"
      end)
  end

  def github_url, do: @github_url

  def hex_package_url, do: @hex_package_url

  def clear_catalog_cache do
    for section <- Catalog.section_definitions() do
      :persistent_term.erase(section_key(section.id))
    end

    :persistent_term.erase(@catalog_count_key)
    :ok
  end

  def clear_section_cache(section_id) when is_binary(section_id) do
    :persistent_term.erase(section_key(section_id))
    :persistent_term.erase(@catalog_count_key)
    :ok
  end

  defp cached_section(%{id: id} = section) do
    key = section_key(id)

    case :persistent_term.get(key, :missing) do
      :missing ->
        built = Catalog.build_section(section)
        :persistent_term.put(key, built)
        built

      built ->
        built
    end
  end

  defp section_key(id), do: {__MODULE__, :section, id}

  defp theme_css_path do
    if File.regular?(@theme_css_fallback), do: @theme_css_fallback, else: nil
  end

  defp asset!(name) do
    case asset_path(name) do
      nil ->
        raise "missing asset mapping for #{inspect(name)}"

      path ->
        File.read!(path)
    end
  end
end
