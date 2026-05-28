defmodule CinderUI.Docs.CatalogTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Docs.Catalog
  alias CinderUI.Docs.UIComponents.Catalog, as: CatalogComponents
  alias CinderUI.Registry

  test "catalog includes all public component functions" do
    expected_count =
      Registry.functions()
      |> length()

    assert Catalog.entry_count() == expected_count
    assert Catalog.functions() == Registry.functions()
    assert Catalog.section_definitions() == Registry.sections()
  end

  test "all entries render without runtime render errors" do
    sections = Catalog.sections()

    assert sections != []

    Enum.each(sections, fn section ->
      assert section.entries != []

      Enum.each(section.entries, fn entry ->
        refute entry.preview_html =~ "Render error"
        assert entry.template_heex =~ "<."
        refute entry.template_heex =~ "CinderUI.Icons.icon"
        assert entry.preview_align in [:center, :full]
        assert is_list(entry.examples)
        assert entry.examples != []

        Enum.each(entry.examples, fn example ->
          refute example.template_heex =~ "CinderUI.Icons.icon"
          assert example.preview_align in [:center, :full]
        end)

        assert is_list(entry.attributes)
        assert is_list(entry.slots)
        assert entry.docs_path == "#{entry.id}/index.html"

        refute entry.docs_full =~ "View live examples and full component docs"

        refute entry.docs_full =~
                 "https://levibuzolic.github.io/cinder_ui/docs/#{String.replace_suffix(entry.docs_path, "index.html", "")}"

        assert entry.shadcn_url =~ "https://ui.shadcn.com/docs/components"
      end)
    end)
  end

  test "component family module docs link to their docs site sections" do
    Enum.each(Catalog.section_definitions(), fn section ->
      {:docs_v1, _, _, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(section.module)

      assert module_doc =~ "View live #{section.title} examples and component docs"
      assert module_doc =~ "https://levibuzolic.github.io/cinder_ui/docs/##{section.id}"
    end)
  end

  test "component metadata and shadcn reference are generated from definitions" do
    button_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == CinderUI.Components.Actions and entry.function == :button
      end)

    assert button_entry
    assert button_entry.shadcn_slug == "button"
    assert button_entry.shadcn_url == "https://ui.shadcn.com/docs/components/button"
    assert button_entry.inline_doc_examples != []
    assert Enum.any?(button_entry.inline_doc_examples, &(&1.title == "Outline small action"))

    assert Enum.any?(
             button_entry.inline_doc_examples,
             &(&1.title == "Loading destructive action")
           )

    attribute_names = Enum.map(button_entry.attributes, & &1.name)
    assert "variant" in attribute_names
    assert "size" in attribute_names
    assert "inner_block" in Enum.map(button_entry.slots, & &1.name)
    assert button_entry.runtime.kind == :server
    assert button_entry.runtime.label == "Server-rendered"
  end

  test "component runtime metadata distinguishes server, progressive, and scaffold entries" do
    entries = Catalog.sections() |> Enum.flat_map(& &1.entries)

    select_entry = find_entry(entries, CinderUI.Components.Forms, :select)
    navigation_menu_entry = find_entry(entries, CinderUI.Components.Navigation, :navigation_menu)
    code_block_entry = find_entry(entries, CinderUI.Components.DataDisplay, :code_block)

    assert select_entry.runtime.kind == :progressive
    assert select_entry.runtime.label == "Progressive"
    assert select_entry.runtime.summary =~ "LiveView hooks"

    assert navigation_menu_entry.runtime.kind == :scaffold
    assert navigation_menu_entry.runtime.label == "Scaffold"
    assert navigation_menu_entry.runtime.summary =~ "extra JS"

    assert code_block_entry.runtime.kind == :progressive
  end

  test "core families expose generated examples extracted from function docs" do
    entries = Catalog.sections() |> Enum.flat_map(& &1.entries)

    assert length(find_entry(entries, CinderUI.Components.Actions, :button).examples) >= 2
    assert length(find_entry(entries, CinderUI.Components.Forms, :field).examples) >= 2
    assert length(find_entry(entries, CinderUI.Components.Layout, :card).examples) >= 2
    assert length(find_entry(entries, CinderUI.Components.Navigation, :tabs).examples) >= 2
    assert length(find_entry(entries, CinderUI.Components.Overlay, :dialog).examples) >= 2
    assert length(find_entry(entries, CinderUI.Components.DataDisplay, :table).examples) >= 2
  end

  test "form field examples with @form shims render as generated previews" do
    input_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == CinderUI.Components.Forms and entry.function == :input
      end)

    assert input_entry
    assert length(input_entry.examples) >= 6

    titles = Enum.map(input_entry.examples, & &1.title)

    assert "With FormField" in titles
    assert "With label" in titles
    assert "With explicit errors" in titles
    assert "Inside field composition" in titles

    form_field_example = Enum.find(input_entry.examples, &(&1.title == "With FormField"))
    composed_example = Enum.find(input_entry.examples, &(&1.title == "Inside field composition"))

    assert form_field_example.phoenix_shim
    assert composed_example.phoenix_shim
    assert form_field_example.preview_html =~ ~s(data-slot="input")
    assert form_field_example.preview_html =~ ~s(name="example[email]")
    assert composed_example.preview_html =~ ~s(data-slot="field")
    assert composed_example.preview_html =~ ~s(for="example_email")
  end

  test "component detail strips nested example docs from residual prose" do
    sections = Catalog.sections()
    entries = Enum.flat_map(sections, & &1.entries)
    input_entry = find_entry(entries, CinderUI.Components.Forms, :input)

    html =
      render_component(&CatalogComponents.docs_component_detail/1, %{
        sections: sections,
        entry: input_entry,
        mode: :static,
        root_prefix: "."
      })

    headings =
      html
      |> Floki.parse_document!()
      |> Floki.find("h3")
      |> Enum.map(fn heading ->
        heading
        |> Floki.text(sep: " ")
        |> String.replace(~r/\s+/, " ")
        |> String.trim()
      end)

    assert html =~ ~s(data-example-title="With FormField")
    assert html =~ ~s(data-example-title="Inside field composition")
    assert Enum.count(headings, &(&1 == "With FormField")) == 1
    assert Enum.count(headings, &(&1 == "Inside field composition")) == 1
  end

  test "composite components can expose doc-derived generated examples" do
    card_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == CinderUI.Components.Layout and entry.function == :card
      end)

    assert card_entry
    assert length(card_entry.examples) >= 2

    extended_example = Enum.find(card_entry.examples, &(&1.template_heex =~ "<.card_footer"))
    minimal_example = Enum.find(card_entry.examples, &(&1.template_heex =~ "<.card_content>"))

    assert extended_example
    assert minimal_example
    assert extended_example.template_heex =~ "<.card_header"
    assert extended_example.template_heex =~ "<.card_footer"
  end

  test "avatar docs samples are sourced from documented usage snippets" do
    avatar_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == CinderUI.Components.DataDisplay and entry.function == :avatar
      end)

    avatar_group_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == CinderUI.Components.DataDisplay and entry.function == :avatar_group
      end)

    assert avatar_entry.template_heex =~ "<.avatar"
    assert avatar_entry.template_heex =~ "example.png"
    assert avatar_entry.template_heex =~ "alt=\"Levi\""
    refute avatar_entry.template_heex =~ "data:image/"
    assert avatar_entry.preview_html =~ "data:image/"
    assert avatar_group_entry.template_heex =~ "<.avatar_group"
    assert avatar_group_entry.template_heex =~ "example.png"
    refute avatar_group_entry.template_heex =~ "data:image/"
    assert avatar_group_entry.preview_html =~ "data:image/"
  end

  test "icons section includes lucide wrapper entry" do
    icon_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == CinderUI.Icons and entry.function == :icon
      end)

    assert icon_entry
    assert icon_entry.template_heex =~ "<.icon"
    assert icon_entry.preview_html =~ "<svg"
    assert icon_entry.docs_full =~ "https://lucide.dev/icons"
    assert icon_entry.docs_full =~ "https://hex.pm/packages/lucide_icons"
  end

  defp find_entry(entries, module, function) do
    Enum.find(entries, fn entry -> entry.module == module and entry.function == function end)
  end
end
