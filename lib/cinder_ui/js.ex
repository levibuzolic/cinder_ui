defmodule CinderUI.JS do
  @moduledoc """
  LiveView JS helpers for controlling interactive Cinder UI components.

  These helpers dispatch the shared `cinder-ui:command` event used by
  commandable hooks such as dialogs, popovers, dropdown menus, selects,
  autocompletes, and comboboxes.

  ## Example

      <button phx-click={CinderUI.JS.open(to: "#account-dialog")}>
        Open dialog
      </button>

      <button phx-click={CinderUI.JS.clear(to: "#owner-autocomplete")}>
        Clear owner
      </button>
  """

  alias Phoenix.LiveView.JS

  @command_event "cinder-ui:command"

  @type command ::
          :open
          | :close
          | :toggle
          | :focus
          | :clear
          | String.t()
          | atom()

  @doc """
  Dispatches a Cinder UI command event to the given selector.

  ## Options

  - `:to` - required DOM selector that identifies the component root.
  - `:detail` - additional event detail merged into the command payload.
  """
  @spec dispatch_command(command(), keyword()) :: JS.t()
  def dispatch_command(command, opts) when is_list(opts) do
    dispatch_command(%JS{}, command, opts)
  end

  @spec dispatch_command(JS.t(), command(), keyword()) :: JS.t()
  def dispatch_command(js \\ %JS{}, command, opts \\ []) do
    {to, opts} = Keyword.pop(opts, :to)
    {detail, _opts} = Keyword.pop(opts, :detail, %{})

    JS.dispatch(js, @command_event,
      to: to,
      detail: Map.put(detail, :command, normalize_command(command))
    )
  end

  @doc """
  Dispatches an `open` command.
  """
  @spec open(keyword()) :: JS.t()
  def open(opts) when is_list(opts), do: open(%JS{}, opts)

  @spec open(JS.t(), keyword()) :: JS.t()
  def open(js \\ %JS{}, opts \\ []), do: dispatch_command(js, :open, opts)

  @doc """
  Dispatches a `close` command.
  """
  @spec close(keyword()) :: JS.t()
  def close(opts) when is_list(opts), do: close(%JS{}, opts)

  @spec close(JS.t(), keyword()) :: JS.t()
  def close(js \\ %JS{}, opts \\ []), do: dispatch_command(js, :close, opts)

  @doc """
  Dispatches a `toggle` command.
  """
  @spec toggle(keyword()) :: JS.t()
  def toggle(opts) when is_list(opts), do: toggle(%JS{}, opts)

  @spec toggle(JS.t(), keyword()) :: JS.t()
  def toggle(js \\ %JS{}, opts \\ []), do: dispatch_command(js, :toggle, opts)

  @doc """
  Dispatches a `focus` command.
  """
  @spec focus(keyword()) :: JS.t()
  def focus(opts) when is_list(opts), do: focus(%JS{}, opts)

  @spec focus(JS.t(), keyword()) :: JS.t()
  def focus(js \\ %JS{}, opts \\ []), do: dispatch_command(js, :focus, opts)

  @doc """
  Dispatches a `clear` command.
  """
  @spec clear(keyword()) :: JS.t()
  def clear(opts) when is_list(opts), do: clear(%JS{}, opts)

  @spec clear(JS.t(), keyword()) :: JS.t()
  def clear(js \\ %JS{}, opts \\ []), do: dispatch_command(js, :clear, opts)

  defp normalize_command(command) when is_atom(command), do: Atom.to_string(command)
  defp normalize_command(command), do: command
end
