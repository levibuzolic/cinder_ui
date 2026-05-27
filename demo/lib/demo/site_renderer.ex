defmodule Demo.SiteRenderer do
  @moduledoc false

  alias CinderUI.Docs.StaticRenderer
  alias CinderUI.Site.Marketing
  alias Demo.SiteRuntime

  def marketing_html do
    Marketing.render_marketing_html(%{
      component_count: SiteRuntime.catalog_component_count(),
      docs_path: "./docs/",
      theme_script_src: "./assets/static_docs.js",
      theme_css_path: "./assets/theme.css",
      site_css_path: "./assets/site.css"
    })
  end

  def docs_index_html do
    sections = SiteRuntime.catalog_sections()

    StaticRenderer.docs_index_html(sections,
      title: "Cinder UI Docs",
      description: "Component docs for Cinder UI",
      component_count: SiteRuntime.catalog_component_count(),
      show_count: true,
      root_prefix: ".",
      home_url: "../",
      asset_prefix: "..",
      github_url: SiteRuntime.github_url(),
      hex_package_url: SiteRuntime.hex_package_url()
    )
  end

  def docs_component_html(entry) do
    sections = SiteRuntime.catalog_sections()

    StaticRenderer.docs_component_html(entry, sections,
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      root_prefix: "..",
      home_url: "../../",
      asset_prefix: "../..",
      github_url: SiteRuntime.github_url(),
      hex_package_url: SiteRuntime.hex_package_url()
    )
  end

  def install_html do
    sections = SiteRuntime.catalog_sections()

    StaticRenderer.install_html(sections,
      title: "Installation · Cinder UI",
      description: "How to install Cinder UI in your Phoenix project",
      root_prefix: "..",
      home_url: "../../",
      asset_prefix: "../..",
      github_url: SiteRuntime.github_url(),
      hex_package_url: SiteRuntime.hex_package_url()
    )
  end
end
