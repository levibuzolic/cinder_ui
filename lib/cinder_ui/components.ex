defmodule CinderUI.Components do
  @moduledoc """
  Aggregates all component modules.
  """

  defmacro __using__(_opts) do
    import_quotes =
      Enum.map(CinderUI.Registry.modules(), fn module ->
        quote do
          import unquote(module)
        end
      end)

    {:__block__, [], import_quotes}
  end
end
