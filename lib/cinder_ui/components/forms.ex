defmodule CinderUI.Components.Forms do
  @moduledoc """
  Form-related components modeled after shadcn/ui.

  Included components:

  - `label/1`
  - `field/1`
  - `field_label/1`
  - `field_control/1`
  - `field_description/1`
  - `field_message/1`
  - `field_error/1`
  - `input/1`
  - `number_field/1`
  - `textarea/1`
  - `checkbox/1`
  - `switch/1`
  - `select/1`
  - `native_select/1`
  - `autocomplete/1`
  - `radio_group/1`
  - `slider/1`
  - `input_group/1`
  - `input_group_addon/1`
  - `input_group_button/1`
  - `input_group_text/1`
  - `input_otp/1`

  [View live Forms examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#forms).
  """

  alias CinderUI.Components.Delegation

  @component_modules [
    {CinderUI.Components.Forms.Field,
     [
       :label,
       :field,
       :field_label,
       :field_control,
       :field_description,
       :field_message,
       :field_error
     ]},
    {CinderUI.Components.Forms.Controls,
     [:input, :number_field, :textarea, :checkbox, :switch, :native_select, :radio_group, :slider]},
    {CinderUI.Components.Forms.Select, [:select, :autocomplete]},
    {CinderUI.Components.Forms.Groups,
     [:input_group, :input_group_addon, :input_group_button, :input_group_text, :input_otp]}
  ]

  for {module, functions} <- @component_modules, function <- functions do
    @doc Delegation.component_doc(module, __MODULE__, function)
    def unquote(function)(assigns), do: unquote(module).unquote(function)(assigns)
  end

  def __components__, do: Delegation.components(@component_modules)
end
