defmodule CinderUI.Docs.Catalog do
  @moduledoc """
  Static documentation catalog used by `mix cinder_ui.docs.build`.

  The catalog renders every public `*/1` component function and returns data
  required to build the static docs site.
  """

  alias CinderUI.Docs.ComponentMetadata
  alias CinderUI.Docs.Examples
  alias CinderUI.Docs.InlineExamples
  alias CinderUI.Registry

  @doc """
  Returns catalog sections and pre-rendered component entries.
  """
  @spec sections() :: [map()]
  def sections do
    Registry.sections()
    |> Enum.map(&build_section/1)
  end

  @doc """
  Build a single section by id.
  """
  @spec build_section(map()) :: map()
  def build_section(%{modules: modules} = section) do
    entries =
      Enum.flat_map(modules, fn module ->
        module
        |> Registry.component_functions()
        |> Enum.map(&entry(module, &1))
      end)

    Map.put(section, :entries, entries)
  end

  def build_section(%{module: module} = section) do
    section
    |> Map.delete(:module)
    |> Map.put(:modules, [module])
    |> build_section()
  end

  @doc """
  Returns the section metadata (without entries) for a given module.
  Returns `nil` if no section matches.
  """
  @spec section_for_module(module()) :: map() | nil
  def section_for_module(module) do
    Registry.section_for_module(module)
  end

  @doc """
  Returns all section definitions (without entries).
  """
  @spec section_definitions() :: [map()]
  def section_definitions, do: Registry.sections()

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
  def functions, do: Registry.functions()

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
      runtime: Registry.runtime(module, function),
      shadcn_slug: slug,
      shadcn_url: ComponentMetadata.shadcn_url(slug),
      docs_path: "#{id}/index.html"
    }
  end
end
