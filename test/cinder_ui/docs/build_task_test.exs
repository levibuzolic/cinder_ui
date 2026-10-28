defmodule CinderUI.Docs.BuildTaskTest do
  use ExUnit.Case, async: false

  import CinderUI.TestHelpers, only: [attr: 3]

  alias CinderUI.Docs.SocialPreview

  @output "dist/site"

  setup do
    File.rm_rf!(@output)
    previous_url = System.get_env("CINDER_UI_SITE_URL")
    System.put_env("CINDER_UI_SITE_URL", "https://docs.example.com/library/")

    on_exit(fn ->
      if previous_url,
        do: System.put_env("CINDER_UI_SITE_URL", previous_url),
        else: System.delete_env("CINDER_UI_SITE_URL")
    end)

    :ok
  end

  test "build task writes unified static site and docs artifacts" do
    Mix.Task.reenable("cinder_ui.docs.build")
    Mix.Task.run("cinder_ui.docs.build", [])

    assert File.exists?(Path.join(@output, "index.html"))
    assert File.exists?(Path.join(@output, ".nojekyll"))
    assert File.exists?(Path.join(@output, "docs/index.html"))
    assert File.exists?(Path.join(@output, "docs/recipes/index.html"))
    assert File.exists?(Path.join(@output, "docs/actions-button/index.html"))
    assert File.exists?(Path.join(@output, "docs/layout-card/index.html"))
    assert File.exists?(Path.join(@output, "docs/assets/site.css"))
    assert File.exists?(Path.join(@output, "docs/assets/static_docs.js"))

    marketing_index = File.read!(Path.join(@output, "index.html"))
    docs_index = File.read!(Path.join(@output, "docs/index.html"))
    recipes_page = File.read!(Path.join(@output, "docs/recipes/index.html"))
    component_page = File.read!(Path.join(@output, "docs/actions-button/index.html"))
    theme_css = File.read!(Path.join(@output, "docs/assets/theme.css"))
    site_js = File.read!(Path.join(@output, "docs/assets/static_docs.js"))
    site_css = File.read!(Path.join(@output, "docs/assets/site.css"))

    assert marketing_index =~ "Cinder UI"
    assert marketing_index =~ "Explore Components"
    assert marketing_index =~ "./docs/"
    assert marketing_index =~ "https://hexdocs.pm/cinder_ui"
    assert marketing_index =~ "GitHub"
    assert marketing_index =~ "Components that shine"
    assert marketing_index =~ ~s(class="code-highlight block min-w-max whitespace-pre")
    assert marketing_index =~ ~s(<span class="tok-keyword">mix</span>)
    assert marketing_index =~ "cui:theme:color"
    assert marketing_index =~ "cui:theme:radius"

    assert docs_index =~ "Component Library"
    assert docs_index =~ "Actions.button"
    assert docs_index =~ "Open docs"
    assert docs_index =~ "./actions-button/"
    assert docs_index =~ "./recipes/"
    assert docs_index =~ ~s(href="../")
    assert docs_index =~ "cui:theme:color"
    assert docs_index =~ "cui:theme:radius"

    assert recipes_page =~ "Recipes"
    assert recipes_page =~ "Settings page"
    assert recipes_page =~ "Admin shell"
    assert recipes_page =~ "Data table"
    assert recipes_page =~ "These are copyable blocks, not new primitives."
    assert recipes_page =~ ~s(data-copy-template="recipe-settings-page")
    assert recipes_page =~ ~s(data-copy-template="recipe-data-table")
    assert recipes_page =~ ~s(href="../")

    assert component_page =~ "Original shadcn/ui docs"
    assert component_page =~ "Attributes"
    assert component_page =~ "Slots"
    assert component_page =~ "https://ui.shadcn.com/docs/components/button"
    refute component_page =~ "View live examples and full component docs"
    assert component_page =~ "https://docs.example.com/library/docs/actions-button/"
    assert component_page =~ ~s(data-slot="preview")
    assert component_page =~ ~s(class="code-highlight block min-w-max whitespace-pre")
    assert component_page =~ ~s(<span class="tok-tag">.button</span>)

    assert theme_css =~ ".accent-primary"
    assert theme_css =~ "accent-color: var(--primary);"
    assert theme_css =~ "color-scheme: dark;"

    assert site_js =~ "initCommandPalette"
    assert site_js =~ "restoreSidebarScroll"
    refute site_js =~ "highlightCodeBlocks"
    refute site_js =~ "CinderUISiteShared"
    assert site_css =~ ".docs-markdown"
    assert site_css =~ ".docs-k-panel"

    component_ids =
      Floki.attribute(Floki.parse_document!(docs_index), "[data-component-card]", "id")

    assert component_ids != []

    for id <- component_ids do
      document =
        @output
        |> Path.join("docs/#{id}/index.html")
        |> File.read!()
        |> Floki.parse_document!()

      image_url = attr(document, "head meta[property='og:image']", "content")
      assert image_url == "https://docs.example.com/library/assets/social/#{id}.png"

      exported_image = File.read!(Path.join(@output, "assets/social/#{id}.png"))
      assert exported_image == File.read!(SocialPreview.image_path(%{id: id}))

      <<_::binary-size(16), width::32, height::32, _::binary>> = exported_image

      assert attr(document, "meta[property='og:image:width']", "content") == to_string(width)
      assert attr(document, "meta[property='og:image:height']", "content") == to_string(height)
      assert attr(document, "meta[name='twitter:image']", "content") == image_url
    end
  end

  test "build task rejects flags and options" do
    assert_raise Mix.Error, fn ->
      Mix.Task.reenable("cinder_ui.docs.build")
      Mix.Task.run("cinder_ui.docs.build", ["--clean"])
    end
  end
end
