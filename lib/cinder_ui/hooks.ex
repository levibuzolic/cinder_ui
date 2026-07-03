defmodule CinderUI.Hooks do
  @moduledoc """
  JS hook integration helpers.

  The hooks ship in `deps/cinder_ui` and `mix cinder_ui.install` wires them into
  your `assets/js/app.js` by importing them from the `cinder_ui` package.
  """

  @doc """
  Returns an import snippet for Phoenix `assets/js/app.js`.
  """
  @spec app_js_snippet() :: String.t()
  def app_js_snippet do
    """
    import { CinderUIHooks } from \"cinder_ui\"
    Object.assign(Hooks, CinderUIHooks)
    """
    |> String.trim()
  end
end
