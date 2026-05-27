defmodule CinderUI.Registry do
  @moduledoc """
  Canonical registry for Cinder UI component modules and metadata.

  The registry intentionally lives in `lib/` so public facades, generated docs,
  and downstream users can share the same component module list without loading
  any dev-only documentation modules at runtime.
  """

  alias CinderUI.Components.Actions
  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.FieldFamily
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Components.Overlay
  alias CinderUI.Icons

  @sections [
    %{id: "actions", title: "Actions", module: Actions},
    %{id: "forms", title: "Forms", modules: [Forms, FieldFamily]},
    %{id: "layout", title: "Layout", module: Layout},
    %{id: "icons", title: "Icons", module: Icons},
    %{id: "feedback", title: "Feedback", module: Feedback},
    %{id: "data-display", title: "Data Display", module: DataDisplay},
    %{id: "navigation", title: "Navigation", module: Navigation},
    %{id: "overlay", title: "Overlay", module: Overlay},
    %{id: "advanced", title: "Advanced", module: Advanced}
  ]

  @runtime_kinds %{
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

  @runtime_definitions %{
    server: %{
      kind: :server,
      label: "Server-rendered",
      summary: "Works with plain server-rendered HEEx and no client hook."
    },
    progressive: %{
      kind: :progressive,
      label: "Progressive",
      summary: "Server-rendered first, with optional LiveView hooks for richer behavior."
    },
    scaffold: %{
      kind: :scaffold,
      label: "Scaffold",
      summary: "Provides the styled API shell; application logic or extra JS is still up to you."
    }
  }

  @doc """
  Returns the canonical component sections.
  """
  @spec sections() :: [%{id: String.t(), title: String.t(), modules: [module()]}]
  def sections, do: @sections

  @doc """
  Returns component modules in canonical section order.
  """
  @spec modules() :: [module()]
  def modules do
    Enum.flat_map(@sections, &section_modules/1)
  end

  @doc """
  Returns public component functions for a registered module.
  """
  @spec component_functions(module()) :: [atom()]
  def component_functions(module) do
    unless registered_module?(module) do
      raise ArgumentError, "unknown CinderUI component module: #{inspect(module)}"
    end

    module
    |> Kernel.apply(:__info__, [:functions])
    |> Enum.filter(fn
      {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
      _ -> false
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  @doc """
  Returns all public `{module, function}` component pairs.
  """
  @spec functions() :: [{module(), atom()}]
  def functions do
    for section <- @sections,
        module <- section_modules(section),
        function <- component_functions(module),
        do: {module, function}
  end

  @doc """
  Returns a map from component function name to its owning module.
  """
  @spec component_modules() :: %{atom() => module()}
  def component_modules do
    Map.new(functions(), fn {module, function} -> {function, module} end)
  end

  @doc """
  Returns the section metadata for a registered module.
  """
  @spec section_for_module(module()) :: map() | nil
  def section_for_module(module) do
    Enum.find(@sections, &(module in section_modules(&1)))
  end

  @doc """
  Returns runtime metadata for a component.
  """
  @spec runtime(module(), atom()) :: %{
          kind: :server | :progressive | :scaffold,
          label: String.t(),
          summary: String.t()
        }
  def runtime(module, function) do
    kind = runtime_kind(module, function)

    Map.fetch!(@runtime_definitions, kind)
  end

  @doc """
  Returns the runtime kind for a component.
  """
  @spec runtime_kind(module(), atom()) :: :server | :progressive | :scaffold
  def runtime_kind(module, function) do
    Map.get(@runtime_kinds, {module, function}, :server)
  end

  defp registered_module?(module), do: module in modules()

  defp section_modules(%{modules: modules}), do: modules
  defp section_modules(%{module: module}), do: [module]
end
