defmodule CinderUI.Docs.CatalogTest do
  use ExUnit.Case, async: true

  alias CinderUI.Docs.Catalog

  @modules [
    CinderUI.Components.Actions,
    CinderUI.Components.Forms,
    CinderUI.Components.Layout,
    CinderUI.Icons,
    CinderUI.Components.Feedback,
    CinderUI.Components.DataDisplay,
    CinderUI.Components.Navigation,
    CinderUI.Components.Overlay,
    CinderUI.Components.Advanced
  ]

  test "catalog includes all public component functions" do
    expected_count =
      @modules
      |> Enum.flat_map(fn module ->
        module
        |> Kernel.apply(:__info__, [:functions])
        |> Enum.filter(fn
          {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
          _ -> false
        end)
      end)
      |> length()

    assert Catalog.entry_count() == expected_count
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
        assert entry.shadcn_url =~ "https://ui.shadcn.com/docs/components"
      end)
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
    calendar_entry = find_entry(entries, CinderUI.Components.Advanced, :calendar)
    code_block_entry = find_entry(entries, CinderUI.Components.DataDisplay, :code_block)

    assert select_entry.runtime.kind == :progressive
    assert select_entry.runtime.label == "Progressive"
    assert select_entry.runtime.summary =~ "LiveView hooks"

    assert calendar_entry.runtime.kind == :scaffold
    assert calendar_entry.runtime.label == "Scaffold"
    assert calendar_entry.runtime.summary =~ "extra JS"

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
