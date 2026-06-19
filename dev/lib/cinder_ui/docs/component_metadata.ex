defmodule CinderUI.Docs.ComponentMetadata do
  @moduledoc false

  alias CinderUI.Registry

  @cinder_docs_base "https://levibuzolic.github.io/cinder_ui/docs"
  @shadcn_base "https://ui.shadcn.com/docs/components"
  @grouped_shadcn_slugs %{
    "alert" => "alert",
    "avatar" => "avatar",
    "breadcrumb" => "breadcrumb",
    "button" => "button",
    "card" => "card",
    "input" => "input",
    "kbd" => "kbd",
    "pagination" => "pagination",
    "table" => "table",
    "toggle" => "toggle"
  }
  @shadcn_slug_overrides %{
    code_block: nil,
    empty_state: "empty",
    field: "form",
    icon: nil,
    input_otp: "input-otp",
    item: "command",
    menu: "navigation-menu"
  }

  def component_functions(module) do
    module
    |> Kernel.apply(:__info__, [:functions])
    |> Enum.filter(fn
      {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
      _ -> false
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  def module_name(module), do: module |> Module.split() |> List.last()

  def module_slug(module) do
    module
    |> module_name()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end

  def function_doc(module, function) do
    with {:docs_v1, _, _, _, _, _, docs} <- Code.fetch_docs(module),
         {{:function, ^function, 1}, _, _, %{"en" => doc}, _}
         when is_binary(doc) <- Enum.find(docs, &doc_entry?(&1, function)) do
      doc
      |> String.trim()
      |> normalize_markdown_indentation()
      |> strip_generated_docs_site_link()
    else
      _ -> "No documentation available."
    end
  end

  def first_paragraph(doc) when is_binary(doc) do
    case doc |> String.split("\n\n") |> List.first() |> String.trim() do
      "" -> "No documentation available."
      paragraph -> paragraph
    end
  end

  def attributes(module, function) do
    module
    |> component_spec(function)
    |> Map.get(:attrs, [])
    |> Enum.map(&normalize_attribute/1)
  end

  def slots(module, function) do
    module
    |> component_spec(function)
    |> Map.get(:slots, [])
    |> Enum.map(&normalize_slot/1)
  end

  def source_line(module, function), do: component_spec(module, function).line

  def runtime(module, function), do: Registry.runtime(module, function)

  def shadcn_slug(function) do
    case Map.fetch(@shadcn_slug_overrides, function) do
      {:ok, slug} ->
        slug

      :error ->
        function
        |> Atom.to_string()
        |> slug_from_name()
    end
  end

  def shadcn_url(nil), do: @shadcn_base
  def shadcn_url(slug), do: "#{@shadcn_base}/#{slug}"

  defp strip_generated_docs_site_link(doc) do
    Regex.replace(
      ~r/\n*\[View live examples and full component docs\]\(#{Regex.escape(@cinder_docs_base)}\/[^)]+\)\.\s*/u,
      doc,
      "\n\n"
    )
    |> String.trim()
  end

  defp normalize_markdown_indentation(doc) do
    if source_indented_markdown?(doc) do
      doc
      |> String.split("\n")
      |> drop_common_source_indent()
      |> Enum.join("\n")
    else
      doc
    end
  end

  defp source_indented_markdown?(doc) do
    Regex.match?(~r/^ {1,3}\#{1,6}\s+\S/m, doc)
  end

  defp drop_common_source_indent(lines) do
    indent =
      lines
      |> Enum.map(&leading_spaces/1)
      |> Enum.reject(&(&1 == 0))
      |> Enum.min(fn -> 0 end)

    Enum.map(lines, &drop_leading_spaces(&1, indent))
  end

  defp leading_spaces(line) do
    case Regex.run(~r/^ */, line) do
      [spaces] -> String.length(spaces)
      nil -> 0
    end
  end

  defp drop_leading_spaces(line, 0), do: line
  defp drop_leading_spaces("", _indent), do: ""

  defp drop_leading_spaces(line, indent),
    do: String.replace_prefix(line, String.duplicate(" ", indent), "")

  defp doc_entry?({{:function, name, 1}, _, _, %{"en" => _}, _}, function), do: name == function
  defp doc_entry?(_, _function), do: false

  defp component_spec(module, function) do
    module
    |> Kernel.apply(:__components__, [])
    |> Map.get(function, %{attrs: [], slots: [], line: nil})
  end

  defp normalize_slot(slot) do
    %{
      name: Atom.to_string(slot.name),
      required: slot.required,
      attrs: slot.attrs |> Enum.map(&normalize_attribute/1)
    }
  end

  defp normalize_attribute(attr) do
    opts = Map.new(attr.opts)
    values = opts |> Map.get(:values, []) |> List.wrap()

    %{
      name: Atom.to_string(attr.name),
      type: inspect(attr.type),
      required: attr.required,
      default: Map.get(opts, :default),
      values: values,
      includes: opts |> Map.get(:include, []) |> List.wrap()
    }
  end

  defp slug_from_name(name) do
    case String.split(name, "_", parts: 2) do
      [prefix, _rest] ->
        Map.get(@grouped_shadcn_slugs, prefix, String.replace(name, "_", "-"))

      _ ->
        String.replace(name, "_", "-")
    end
  end
end
