defmodule CinderUI do
  @moduledoc """
  Entry-point helpers for the Cinder UI component system.

  ## Usage

      # Import all components (for new projects or when replacing CoreComponents)
      use CinderUI

      # Optionally import shorthand typography aliases like <.h1> and <.lead>
      use CinderUI, typography: true

      # Exclude specific components to avoid conflicts with CoreComponents
      use CinderUI, except: [:button, :card, :flash, :flash_group, :input, :label, :table]

  When using `except`, excluded components can still be accessed via their full
  module namespace (e.g., `<CinderUI.Components.Actions.button>`) or through the
  `CinderUI.UI` facade module (e.g., `alias CinderUI.UI` then `<UI.button>`).
  """

  @typography_alias_module CinderUI.Components.Typography

  defmacro __using__(opts) do
    excluded = Keyword.get(opts, :except, [])
    typography? = Keyword.get(opts, :typography, false)

    unless is_boolean(typography?) do
      raise ArgumentError, "`use CinderUI, typography:` expects a boolean"
    end

    component_modules =
      if typography? do
        Map.merge(CinderUI.Registry.component_modules(), typography_alias_modules())
      else
        CinderUI.Registry.component_modules()
      end

    unknown = excluded -- Map.keys(component_modules)

    if unknown != [] do
      raise ArgumentError,
            "unknown component(s) in `use CinderUI, except:`: #{inspect(unknown)}"
    end

    # Group excluded functions by their source module.
    exclusions_by_module =
      excluded
      |> Enum.group_by(&Map.fetch!(component_modules, &1))
      |> Map.new(fn {mod, funcs} -> {mod, Enum.map(funcs, &{&1, 1})} end)

    imports =
      for mod <- CinderUI.Registry.modules() do
        exclusions = Map.get(exclusions_by_module, mod)

        cond do
          mod == @typography_alias_module and not typography? ->
            default_typography_import(exclusions)

          is_nil(exclusions) ->
            quote do: import(unquote(mod))

          true ->
            quote do: import(unquote(mod), except: unquote(exclusions))
        end
      end

    quote do
      use Phoenix.Component
      unquote_splicing(imports)
      import CinderUI.Classes
    end
  end

  defp typography_alias_modules do
    @typography_alias_module
    |> Kernel.apply(:__info__, [:functions])
    |> Enum.filter(fn
      {:typography, 1} -> false
      {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
      _ -> false
    end)
    |> Map.new(fn {function, 1} -> {function, @typography_alias_module} end)
  end

  defp default_typography_import(exclusions) do
    if List.keymember?(List.wrap(exclusions), :typography, 0) do
      quote do
      end
    else
      quote do: import(CinderUI.Components.Typography, only: [typography: 1])
    end
  end
end
