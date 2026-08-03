defmodule CinderUI.ComponentDocsTest do
  use ExUnit.Case, async: false

  test "doc/1 macro handles binary markdown variants during compilation" do
    module = unique_module("Probe")
    module_slug = module_slug(module)
    file = write_module_file(module, source_with_docs(module, module_slug))

    [{^module, _beam}] = Code.compile_file(file)

    assert module.first(:ok) == :ok
    assert module.legacy(:ok) == :ok
    assert module.already(:ok) == :ok

    assert CinderUI.ComponentDocs.component_docs_url(module, :first) ==
             "https://levibuzolic.github.io/cinder_ui/docs/#{module_slug}-first/"
  end

  test "doc/1 macro passes through non-binary docs" do
    module = unique_module("FalseProbe")
    file = write_module_file(module, source_with_false_doc(module))

    [{^module, _beam}] = Code.compile_file(file)
    assert module.hidden(:ok) == :ok
  end

  test "section_docs_url/1 returns docs site anchors for component family modules" do
    assert CinderUI.ComponentDocs.section_docs_url(CinderUI.Components.Forms) ==
             "https://levibuzolic.github.io/cinder_ui/docs/#forms"

    assert CinderUI.ComponentDocs.section_docs_url(CinderUI.Components.DataDisplay) ==
             "https://levibuzolic.github.io/cinder_ui/docs/#data-display"
  end

  test "compiled component docs append the live examples link without a section heading" do
    doc = compiled_function_doc(CinderUI.Components.Forms, :input)

    assert doc =~ "## Screenshot"
    refute doc =~ "## Interactive docs"

    assert doc =~
             "![input/1 screenshot](screenshots/forms-input.png)\n\n[View live examples and full component docs](https://levibuzolic.github.io/cinder_ui/docs/forms-input/)."
  end

  test "doc/1 normalizes indented markdown and preserves generated sections" do
    module = unique_module("IndentedProbe")
    module_slug = module_slug(module)

    file =
      write_module_file(
        module,
        source_with_indented_and_generated_docs(module, module_slug)
      )

    [{^module, beam}] = compile_with_docs(file)
    beam_file = Path.rootname(file) <> ".beam"
    File.write!(beam_file, beam)

    indented_doc = compiled_function_doc(beam_file, :indented)
    assert indented_doc =~ "# Heading\n  Nested detail"
    refute indented_doc =~ "  # Heading"

    generated_doc = compiled_function_doc(beam_file, :generated)
    assert length(:binary.matches(generated_doc, "screenshots/#{module_slug}-generated.png")) == 1

    assert length(
             :binary.matches(
               generated_doc,
               "https://levibuzolic.github.io/cinder_ui/docs/#{module_slug}-generated/"
             )
           ) == 1
  end

  test "doc/1 leaves orphaned documentation unchanged" do
    module = unique_module("OrphanProbe")
    file = write_module_file(module, source_with_orphan_doc(module))

    [{^module, _beam}] = Code.compile_file(file)
  end

  defp unique_module(suffix) do
    Module.concat([
      CinderUI,
      DocsTest,
      String.to_atom("#{suffix}#{System.unique_integer([:positive])}")
    ])
  end

  defp write_module_file(module, source) do
    tmp_dir = Path.join(System.tmp_dir!(), "cinder-ui-component-docs-test")
    File.mkdir_p!(tmp_dir)

    file =
      Path.join(
        tmp_dir,
        "#{module |> Module.split() |> Enum.join("_") |> Macro.underscore()}.ex"
      )

    File.mkdir_p!(Path.dirname(file))
    File.write!(file, source)
    file
  end

  defp source_with_docs(module, module_slug) do
    """
    defmodule #{inspect(module)} do
      require CinderUI.ComponentDocs

      CinderUI.ComponentDocs.doc \"\"\"
      First docs
      \"\"\"

      # Keep one non-matching line so documented_function/2 exercises the nil regex branch first.
      def first(assigns), do: assigns

      CinderUI.ComponentDocs.doc \"\"\"
      Legacy screenshot path.
      ![legacy](doc/screenshots/legacy.png)
      \"\"\"
      def legacy(assigns), do: assigns

      CinderUI.ComponentDocs.doc \"\"\"
      Has an explicit screenshot already.
      ![already](screenshots/#{module_slug}-already.png)
      \"\"\"
      def already(assigns), do: assigns
    end
    """
  end

  defp source_with_false_doc(module) do
    """
    defmodule #{inspect(module)} do
      require CinderUI.ComponentDocs

      CinderUI.ComponentDocs.doc false
      def hidden(assigns), do: assigns
    end
    """
  end

  defp source_with_indented_and_generated_docs(module, module_slug) do
    """
    defmodule #{inspect(module)} do
      require CinderUI.ComponentDocs

      CinderUI.ComponentDocs.doc "  # Heading\n    Nested detail\n\n"
      def indented(assigns), do: assigns

      CinderUI.ComponentDocs.doc \"\"\"
      Existing generated sections.

      ![generated](screenshots/#{module_slug}-generated.png)

      [View live examples and full component docs](https://levibuzolic.github.io/cinder_ui/docs/#{module_slug}-generated/).
      \"\"\"
      def generated(assigns), do: assigns
    end
    """
  end

  defp source_with_orphan_doc(module) do
    """
    defmodule #{inspect(module)} do
      require CinderUI.ComponentDocs

      CinderUI.ComponentDocs.doc "Orphaned docs"
    end
    """
  end

  defp compiled_function_doc(module_or_path, function) do
    {:docs_v1, _, _, _, _, _, docs} = Code.fetch_docs(module_or_path)

    assert {{:function, ^function, 1}, _, _, %{"en" => doc}, _} =
             Enum.find(docs, fn
               {{:function, name, 1}, _, _, _, _} -> name == function
               _ -> false
             end)

    doc
  end

  defp compile_with_docs(file) do
    compiler_options = Code.compiler_options()
    Code.compiler_options(docs: true)

    try do
      Code.compile_file(file)
    after
      Code.compiler_options(compiler_options)
    end
  end

  defp module_slug(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end
end
