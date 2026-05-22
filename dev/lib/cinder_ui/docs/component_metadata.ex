defmodule CinderUI.Docs.ComponentMetadata do
  @moduledoc false

  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Components.Overlay

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
  @component_runtimes %{
    {Forms, :autocomplete} => :progressive,
    {Forms, :input_otp} => :progressive,
    {Forms, :select} => :progressive,
    {Layout, :resizable} => :progressive,
    {DataDisplay, :code_block} => :progressive,
    {Navigation, :navigation_menu} => :scaffold,
    {Overlay, :alert_dialog} => :progressive,
    {Overlay, :dialog} => :progressive,
    {Overlay, :drawer} => :progressive,
    {Overlay, :dropdown_menu} => :progressive,
    {Overlay, :menubar} => :progressive,
    {Overlay, :popover} => :progressive,
    {Overlay, :sheet} => :progressive,
    {Advanced, :carousel} => :progressive,
    {Advanced, :chart} => :scaffold,
    {Advanced, :combobox} => :progressive,
    {Advanced, :sidebar} => :progressive,
    {Advanced, :sidebar_layout} => :progressive
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

  def runtime(module, function) do
    module
    |> then(&Map.get(@component_runtimes, {&1, function}, :server))
    |> runtime_definition()
  end

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
    String.replace(
      doc,
      ~r/\n*\[View live examples and full component docs\]\(#{Regex.escape(@cinder_docs_base)}\/[^)]+\)\.\s*/u,
      ""
    )
  end

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

  defp runtime_definition(:server) do
    %{
      kind: :server,
      label: "Server-rendered",
      summary: "Works with plain server-rendered HEEx and no client hook."
    }
  end

  defp runtime_definition(:progressive) do
    %{
      kind: :progressive,
      label: "Progressive",
      summary: "Server-rendered first, with optional LiveView hooks for richer behavior."
    }
  end

  defp runtime_definition(:scaffold) do
    %{
      kind: :scaffold,
      label: "Scaffold",
      summary: "Provides the styled API shell; application logic or extra JS is still up to you."
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
