defmodule Demo.SiteRuntime do
  @moduledoc false

  alias CinderUI.Docs.Catalog

  @repo_root Path.expand("../../..", __DIR__)
  @docs_assets_dir Path.join(@repo_root, "dev/assets/docs")
  @site_assets_dir Path.join(@repo_root, "dev/assets/site")
  @theme_css_fallback Path.expand("../../priv/static/assets/css/app.css", __DIR__)

  @catalog_sections_key {__MODULE__, :catalog_sections}
  @catalog_count_key {__MODULE__, :catalog_count}

  def asset_path(path) when is_binary(path) do
    case path do
      "site.js" -> Path.join(@docs_assets_dir, "site.js")
      "shared.js" -> Path.join(@site_assets_dir, "shared.js")
      "site.css" -> Path.join(@site_assets_dir, "site.css")
      "theme.css" -> theme_css_path()
      _ -> nil
    end
  end

  def docs_site_js do
    [asset!("shared.js"), asset!("site.js")]
    |> Enum.join(";\n\n")
    |> Kernel.<>(";\n")
  end

  def catalog_sections do
    case :persistent_term.get(@catalog_sections_key, :missing) do
      :missing ->
        sections = Catalog.sections()
        :persistent_term.put(@catalog_sections_key, sections)
        sections

      sections ->
        sections
    end
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

  def clear_catalog_cache do
    :persistent_term.erase(@catalog_sections_key)
    :persistent_term.erase(@catalog_count_key)
    :ok
  end

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
