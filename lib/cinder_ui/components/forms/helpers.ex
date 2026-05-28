defmodule CinderUI.Components.Forms.Helpers do
  @moduledoc false

  import Phoenix.Component, only: [assign: 3]

  def text_input_base_classes do
    [
      form_control_base_classes(),
      form_control_state_classes(),
      "text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 h-9 w-full min-w-0 rounded-md bg-transparent px-3 py-1 text-base md:text-sm"
    ]
  end

  def form_control_base_classes do
    "border-input border shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50"
  end

  def form_control_state_classes do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
      "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive"
    ]
  end

  # -- FormField helpers -------------------------------------------------------

  def unwrap_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    raw_errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
    translated = Enum.map(raw_errors, &translate_error/1)

    assigns
    |> assign(:field, nil)
    |> then(fn a -> if is_nil(a[:id]), do: assign(a, :id, field.id), else: a end)
    |> then(fn a -> if is_nil(a[:name]), do: assign(a, :name, field.name), else: a end)
    |> then(fn a -> if is_nil(a[:value]), do: assign(a, :value, field.value), else: a end)
    |> maybe_put_errors(translated)
  end

  def unwrap_field(assigns), do: assigns

  defp maybe_put_errors(%{errors: errors} = assigns, _auto_errors) when not is_nil(errors),
    do: assigns

  defp maybe_put_errors(assigns, errors), do: assign(assigns, :errors, errors)

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def selected_option(options, value) when is_list(options) and is_binary(value) do
    Enum.find(options, &(&1.value == value))
  end

  def selected_option(_options, _value), do: nil

  def input_otp_separator_indexes(groups, length) do
    groups
    |> Enum.map_reduce(0, fn group_size, offset ->
      next_offset = offset + group_size
      {next_offset - 1, next_offset}
    end)
    |> elem(0)
    |> Enum.filter(&(&1 >= 0 and &1 < length - 1))
  end
end
