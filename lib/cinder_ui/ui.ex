defmodule CinderUI.UI do
  @moduledoc """
  Facade module that delegates every component function, allowing conflict-free
  access via a single alias.

  ## Usage

      # In your html_helpers
      alias CinderUI.UI

      # In templates
      <UI.button>Click me</UI.button>
      <UI.autocomplete id="search" name="q" value="">
        <:option value="foo" label="Foo" />
      </UI.autocomplete>

  This is useful in projects that have existing components (e.g., Phoenix
  CoreComponents) with overlapping names like `button`, `input`, or `table`.
  """

  for {mod, func} <- CinderUI.Registry.functions() do
    @doc false
    def unquote(func)(assigns), do: unquote(mod).unquote(func)(assigns)
  end
end
