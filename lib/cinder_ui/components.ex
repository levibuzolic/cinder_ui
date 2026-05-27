defmodule CinderUI.Components do
  @moduledoc """
  Aggregates all component modules.

  Named typography aliases such as `h1/1` and `lead/1` are intentionally not
  imported by default. Pass `typography: true` to opt in.
  """

  @typography_alias_module CinderUI.Components.Typography

  defmacro __using__(opts) do
    typography? = Keyword.get(opts, :typography, false)

    unless is_boolean(typography?) do
      raise ArgumentError, "`use CinderUI.Components, typography:` expects a boolean"
    end

    import_quotes =
      Enum.map(CinderUI.Registry.modules(), fn module ->
        cond do
          module == @typography_alias_module and typography? ->
            quote do
              import CinderUI.Components.Typography
            end

          module == @typography_alias_module ->
            quote do
              import CinderUI.Components.Typography, only: [typography: 1]
            end

          true ->
            quote do
              import unquote(module)
            end
        end
      end)

    {:__block__, [], import_quotes}
  end
end
