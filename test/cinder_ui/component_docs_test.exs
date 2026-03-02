defmodule CinderUI.ComponentDocsTest do
  use ExUnit.Case, async: false

  test "doc/1 macro handles binary markdown variants during compilation" do
    module = unique_module("Probe")
    module_slug = module_slug(module)
    file = write_module_file(module, source_with_docs(module, module_slug))

    [{^module, _beam}] = Code.compile_file(file)

    assert apply(module, :first, [:ok]) == :ok
    assert apply(module, :legacy, [:ok]) == :ok
    assert apply(module, :already, [:ok]) == :ok
  end

  test "doc/1 macro passes through non-binary docs" do
    module = unique_module("FalseProbe")
    file = write_module_file(module, source_with_false_doc(module))

    [{^module, _beam}] = Code.compile_file(file)
    assert apply(module, :hidden, [:ok]) == :ok
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

  defp module_slug(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end
end
