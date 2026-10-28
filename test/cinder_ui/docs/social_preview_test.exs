defmodule CinderUI.Docs.SocialPreviewTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest
  import CinderUI.TestHelpers, only: [attr: 3]

  alias CinderUI.Docs.SocialPreview

  @entry %{
    id: "layout-card_title",
    module_name: "Layout",
    title: "card_title",
    docs: ~s(A title with "quotes" & <markup>.)
  }

  setup do
    previous_url = System.get_env("CINDER_UI_SITE_URL")
    System.delete_env("CINDER_UI_SITE_URL")

    on_exit(fn ->
      if previous_url,
        do: System.put_env("CINDER_UI_SITE_URL", previous_url),
        else: System.delete_env("CINDER_UI_SITE_URL")
    end)
  end

  test "renders crawler-readable metadata with escaped text and the production URL" do
    document = render_component(&SocialPreview.meta/1, entry: @entry) |> Floki.parse_document!()

    assert attr(document, "link[rel=canonical]", "href") ==
             "https://levibuzolic.github.io/cinder_ui/docs/layout-card_title/"

    assert attr(document, "meta[property='og:title']", "content") ==
             "Layout.card_title · Cinder UI"

    assert attr(document, "meta[property='og:description']", "content") == @entry.docs
    assert attr(document, "meta[property='og:image:type']", "content") == "image/png"

    assert attr(document, "meta[property='og:image:alt']", "content") ==
             "Layout.card_title component preview"

    assert attr(document, "meta[name='twitter:card']", "content") == "summary_large_image"
  end

  test "rejects invalid public roots instead of publishing broken image URLs" do
    for url <- [
          "/relative",
          "ftp://example.com",
          "https://example.com?x=1",
          "https://example.com/#docs"
        ] do
      System.put_env("CINDER_UI_SITE_URL", url)

      assert_raise ArgumentError, ~r/CINDER_UI_SITE_URL/, fn ->
        render_component(&SocialPreview.meta/1, entry: @entry)
      end
    end
  end
end
