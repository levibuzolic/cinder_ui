defmodule CinderUI.Components.Advanced do
  @moduledoc """
  Higher-level components that map to shadcn patterns with progressive enhancement.

  Included:

  - `command/1`
  - `combobox/1`
  - `carousel/1`
  - `chart/1`
  - `sidebar_layout/1`
  - `sidebar/1`
  - `sidebar_main/1`
  - `sidebar_header/1`
  - `sidebar_footer/1`
  - `sidebar_group/1`
  - `sidebar_item/1`
  - `sidebar_profile_menu/1`
  - `sidebar_trigger/1`
  - `item/1`

  These components intentionally favor no-JS defaults and expose hooks/classes so
  advanced interactions can be layered in using LiveView hooks.

  [View live Advanced examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#advanced).
  """

  alias CinderUI.Components.Delegation

  @component_modules [
    {CinderUI.Components.Advanced.Command, [:command, :item, :combobox]},
    {CinderUI.Components.Advanced.Media, [:carousel, :chart]},
    {CinderUI.Components.Advanced.Sidebar,
     [
       :sidebar_layout,
       :sidebar,
       :sidebar_main,
       :sidebar_header,
       :sidebar_footer,
       :sidebar_group,
       :sidebar_item,
       :sidebar_profile_menu,
       :sidebar_trigger
     ]}
  ]

  for {module, functions} <- @component_modules, function <- functions do
    @doc Delegation.component_doc(module, __MODULE__, function)
    def unquote(function)(assigns), do: unquote(module).unquote(function)(assigns)
  end

  def __components__, do: Delegation.components(@component_modules)
end
