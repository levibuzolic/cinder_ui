defmodule CinderUI.Docs.Catalog do
  @moduledoc """
  Static documentation catalog used by `mix cinder_ui.docs.build`.

  The catalog renders every public `*/1` component function and returns data
  required to build the static docs site.
  """

  alias CinderUI.Components.Actions
  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Components.Overlay
  alias CinderUI.Docs.ComponentMetadata
  alias CinderUI.Docs.Examples
  alias CinderUI.Docs.InlineExamples
  alias CinderUI.Icons

  @sections [
    %{id: "actions", title: "Actions", module: Actions},
    %{id: "forms", title: "Forms", module: Forms},
    %{id: "layout", title: "Layout", module: Layout},
    %{id: "icons", title: "Icons", module: Icons},
    %{id: "feedback", title: "Feedback", module: Feedback},
    %{id: "data-display", title: "Data Display", module: DataDisplay},
    %{id: "navigation", title: "Navigation", module: Navigation},
    %{id: "overlay", title: "Overlay", module: Overlay},
    %{id: "advanced", title: "Advanced", module: Advanced}
  ]

  @doc """
  Returns catalog sections and pre-rendered component entries.
  """
  @spec sections() :: [map()]
  def sections do
    Enum.map(@sections, &build_section/1)
  end

  @doc """
  Build a single section by id.
  """
  @spec build_section(map()) :: map()
  def build_section(%{module: module} = section) do
    entries =
      module
      |> ComponentMetadata.component_functions()
      |> Enum.map(&entry(module, &1))

    Map.put(section, :entries, entries)
  end

  @doc """
  Returns the section metadata (without entries) for a given module.
  Returns `nil` if no section matches.
  """
  @spec section_for_module(module()) :: map() | nil
  def section_for_module(module) do
    Enum.find(@sections, &(&1.module == module))
  end

  @doc """
  Returns all section definitions (without entries).
  """
  @spec section_definitions() :: [map()]
  def section_definitions, do: @sections

  @doc """
  Total number of component entries in the catalog.
  """
  @spec entry_count() :: non_neg_integer()
  def entry_count do
    sections()
    |> Enum.flat_map(& &1.entries)
    |> length()
  end

  @doc """
  Returns list of all component `{module, function}` pairs.
  """
  @spec functions() :: [{module(), atom()}]
  def functions do
    for section <- @sections,
        function <- ComponentMetadata.component_functions(section.module),
        do: {section.module, function}
  end

  defp entry(module, function) do
    doc = ComponentMetadata.function_doc(module, function)
    inline_doc_examples = InlineExamples.parse(doc)
    generated_examples = Examples.build(module, function, inline_doc_examples)
    primary_example = List.first(generated_examples)
    id = "#{ComponentMetadata.module_slug(module)}-#{function}"
    slug = ComponentMetadata.shadcn_slug(function)

    %{
      id: id,
      title: Atom.to_string(function),
      function: function,
      module: module,
      module_name: ComponentMetadata.module_name(module),
      docs: ComponentMetadata.first_paragraph(doc),
      docs_full: doc,
      preview_html: primary_example.preview_html,
      template_heex: primary_example.template_heex,
      preview_align: primary_example.preview_align || :center,
      examples: generated_examples,
      inline_doc_examples: inline_doc_examples,
      attributes: ComponentMetadata.attributes(module, function),
      slots: ComponentMetadata.slots(module, function),
      source_line: ComponentMetadata.source_line(module, function),
      runtime: ComponentMetadata.runtime(module, function),
      shadcn_slug: slug,
      shadcn_url: ComponentMetadata.shadcn_url(slug),
      docs_path: "#{id}/index.html"
    }
  end
end
