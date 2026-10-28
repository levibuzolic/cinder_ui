defmodule CinderUI.Docs.SocialPreview do
  @moduledoc """
  Component link previews using committed Playwright snapshots.

  Both exporters copy the PNGs to `assets/social/`. Set `CINDER_UI_SITE_URL` to
  override the default GitHub Pages root, including any hosting subpath.
  """

  use Phoenix.Component

  @snapshot_dir Path.expand("../../../../demo/tests/browser/visual.spec.ts-snapshots", __DIR__)
  @default_site_url "https://levibuzolic.github.io/cinder_ui"

  def image_path(entry) do
    filename = "cards-#{String.replace(entry.id, "_", "-")}.png"
    Path.join(@snapshot_dir, filename)
  end

  def export_images!(entries, output_dir) do
    destination = Path.join(output_dir, "assets/social")
    File.mkdir_p!(destination)

    for entry <- entries do
      File.cp!(image_path(entry), Path.join(destination, "#{entry.id}.png"))
    end
  end

  attr :entry, :map, required: true

  def meta(assigns) do
    entry = assigns.entry
    base_url = site_url()
    component_name = "#{entry.module_name}.#{entry.title}"

    <<137, "PNG\r\n", 26, "\n", 13::32, "IHDR", width::32, height::32, _::binary>> =
      File.read!(image_path(entry))

    assigns =
      assigns
      |> assign(:title, "#{component_name} · Cinder UI")
      |> assign(:url, "#{base_url}/docs/#{entry.id}/")
      |> assign(:image_url, "#{base_url}/assets/social/#{entry.id}.png")
      |> assign(:image_alt, "#{component_name} component preview")
      |> assign(:width, width)
      |> assign(:height, height)

    ~H"""
    <link rel="canonical" href={@url} />
    <meta property="og:type" content="website" />
    <meta property="og:site_name" content="Cinder UI" />
    <meta property="og:title" content={@title} />
    <meta property="og:description" content={@entry.docs} />
    <meta property="og:url" content={@url} />
    <meta property="og:image" content={@image_url} />
    <meta property="og:image:type" content="image/png" />
    <meta property="og:image:width" content={@width} />
    <meta property="og:image:height" content={@height} />
    <meta property="og:image:alt" content={@image_alt} />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content={@title} />
    <meta name="twitter:description" content={@entry.docs} />
    <meta name="twitter:image" content={@image_url} />
    <meta name="twitter:image:alt" content={@image_alt} />
    """
  end

  defp site_url do
    configured_url = System.get_env("CINDER_UI_SITE_URL")
    base_url = if configured_url in [nil, ""], do: @default_site_url, else: configured_url
    uri = URI.parse(base_url)

    unless uri.scheme in ["http", "https"] and uri.host not in [nil, ""] and
             is_nil(uri.query) and is_nil(uri.fragment) and is_nil(uri.userinfo) do
      raise ArgumentError,
            "CINDER_UI_SITE_URL must be an absolute HTTP(S) URL without a query or fragment"
    end

    String.trim_trailing(base_url, "/")
  end
end
