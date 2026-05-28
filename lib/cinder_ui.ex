defmodule CinderUI do
  @moduledoc """
  Entry-point helpers for the Cinder UI component system.

  ## Usage

      # Import all components (for new projects or when replacing CoreComponents)
      use CinderUI

      # Exclude specific components to avoid conflicts with CoreComponents
      use CinderUI, except: [:button, :card, :flash, :flash_group, :input, :label, :table]

  When using `except`, excluded components can still be accessed via their full
  module namespace (e.g., `<CinderUI.Components.Actions.button>`) or through the
  `CinderUI.UI` facade module (e.g., `alias CinderUI.UI` then `<UI.button>`).
  """

  defmacro __using__(opts) do
    excluded = Keyword.get(opts, :except, [])
    component_modules = CinderUI.Registry.component_modules()
    all_modules = CinderUI.Registry.modules()

    unknown = excluded -- Map.keys(component_modules)

    if unknown != [] do
      raise ArgumentError,
            "unknown component(s) in `use CinderUI, except:`: #{inspect(unknown)}"
    end

    # Group excluded functions by their source module
    exclusions_by_module =
      excluded
      |> Enum.group_by(&Map.fetch!(component_modules, &1))
      |> Map.new(fn {mod, funcs} -> {mod, Enum.map(funcs, &{&1, 1})} end)

    imports =
      for mod <- all_modules do
        case Map.get(exclusions_by_module, mod) do
          nil ->
            quote do: import(unquote(mod))

          except_list ->
            quote do: import(unquote(mod), except: unquote(except_list))
        end
      end

    quote do
      use Phoenix.Component
      unquote_splicing(imports)
      import CinderUI.Classes
    end
  end
end
