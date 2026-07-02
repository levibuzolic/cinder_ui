defmodule CinderUI.Components.Forms.Groups do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]
  import CinderUI.Components.Forms.Field, only: [field_error: 1, label: 1]
  import CinderUI.Components.Forms.Helpers

  doc("""
  Wraps an input and sibling controls (buttons/icons) in a single inline group.

  Use `input_group_addon/1` for static text, icons, status copy, or compact
  buttons that should visually attach to the grouped controls.

  ## Examples

  ```heex title="Search with action" align="full"
  <.input_group>
    <.input placeholder="Search" />
    <.input_group_addon>
      <.input_group_button variant={:secondary}>Go</.input_group_button>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Handle input" align="full"
  <.input_group>
    <.input placeholder="organization" />
    <.input_group_addon>
      <.input_group_text>@company.com</.input_group_text>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="URL builder" align="full"
  <.input_group>
    <.input_group_addon>
      <.input_group_text>https://</.input_group_text>
    </.input_group_addon>
    <.input value="cinder-ui" />
    <.input_group_addon>
      <.input_group_text>.com</.input_group_text>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Command search" align="full"
  <.input_group>
    <.input_group_addon>
      <.icon name="search" class="size-4" />
    </.input_group_addon>
    <.input placeholder="Search components" />
    <.input_group_addon>
      <.kbd>⌘K</.kbd>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Loading state" align="full"
  <.input_group>
    <.input placeholder="Generating invite link..." disabled />
    <.input_group_addon>
      <.spinner class="size-4" />
      <.input_group_text>Syncing</.input_group_text>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Select + input" align="full"
  <.input_group>
    <.native_select name="team-role" value="admin" class="w-32" aria-label="Team role">
      <:option value="admin" label="Admin" />
      <:option value="editor" label="Editor" />
      <:option value="viewer" label="Viewer" />
    </.native_select>
    <.input placeholder="email@example.com" type="email" class="flex-1" />
  </.input_group>
  ```

  ```heex title="Textarea with footer action" align="full"
  <.input_group align={:block_end}>
    <.textarea
      rows={3}
      placeholder="Write a comment..."
      class="min-h-[5.5rem]"
    />
    <.input_group_addon align={:block_end}>
      <span>0/280</span>
      <.button size={:sm}>Post</.button>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Copy URL action" align="full"
  <.input_group>
    <.input placeholder="https://example.com" />
    <.input_group_addon>
      <.input_group_button variant={:outline}>Copy</.input_group_button>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Icon actions" align="full"
  <.input_group>
    <.input value="ck_live_************************" readonly />
    <.input_group_addon>
      <.input_group_button size={:icon_xs} aria-label="Reveal key">
        <.icon name="eye" />
      </.input_group_button>
      <.input_group_button size={:icon_xs} aria-label="Copy key">
        <.icon name="copy" />
      </.input_group_button>
    </.input_group_addon>
  </.input_group>
  ```
  """)

  attr :align, :atom, default: :inline, values: [:inline, :block_end]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def input_group(assigns) do
    assigns =
      assigns
      |> assign(:align_attr, if(assigns.align == :block_end, do: "block-end", else: "inline"))
      |> assign(:classes, [
        "dark:bg-input/30 relative flex w-full min-w-0 rounded-md border border-input bg-transparent shadow-xs transition-[color,box-shadow]",
        assigns.align == :inline && "h-9 items-center",
        assigns.align == :block_end && "min-h-9 flex-col items-stretch",
        "has-[:focus-visible]:border-ring has-[:focus-visible]:ring-ring/50 has-[:focus-visible]:ring-[3px]",
        "[&>*]:relative [&>*]:min-w-0 [&>*]:focus-visible:z-10",
        assigns.align == :inline &&
          "[&>*:first-child]:rounded-l-md [&>*:last-child]:rounded-r-md [&>*:only-child]:rounded-md",
        assigns.align == :inline &&
          "[&>*:not(:last-child)]:border-r [&>*:not(:last-child)]:border-input",
        "[&>[data-slot=input-group-addon]]:text-muted-foreground [&>[data-slot=input-group-addon]]:inline-flex [&>[data-slot=input-group-addon]]:shrink-0 [&>[data-slot=input-group-addon]]:items-center [&>[data-slot=input-group-addon]]:justify-center [&>[data-slot=input-group-addon]]:gap-2 [&>[data-slot=input-group-addon]]:text-sm",
        assigns.align == :inline &&
          "[&>[data-slot=input-group-addon]]:h-full [&>[data-slot=input-group-addon]]:px-3 [&>[data-slot=input-group-addon]]:leading-none",
        assigns.align == :block_end &&
          "[&>[data-slot=input-group-addon][data-align=block-end]]:w-full [&>[data-slot=input-group-addon][data-align=block-end]]:items-center [&>[data-slot=input-group-addon][data-align=block-end]]:justify-between [&>[data-slot=input-group-addon][data-align=block-end]]:border-t [&>[data-slot=input-group-addon][data-align=block-end]]:border-input [&>[data-slot=input-group-addon][data-align=block-end]]:bg-muted/20 [&>[data-slot=input-group-addon][data-align=block-end]]:px-3 [&>[data-slot=input-group-addon][data-align=block-end]]:py-2",
        "[&>[data-slot=input]]:h-full [&>[data-slot=input]]:flex-1 [&>[data-slot=input]]:rounded-none [&>[data-slot=input]]:border-0 [&>[data-slot=input]]:bg-transparent [&>[data-slot=input]]:px-3 [&>[data-slot=input]]:py-1 [&>[data-slot=input]]:shadow-none [&>[data-slot=input]]:focus-visible:ring-0",
        "[&>[data-slot=autocomplete]]:h-full [&>[data-slot=autocomplete]]:flex-1 [&>[data-slot=autocomplete]]:min-w-0 [&>[data-slot=combobox]]:h-full [&>[data-slot=combobox]]:flex-1 [&>[data-slot=combobox]]:min-w-0",
        "[&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:h-full [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:rounded-none [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:border-0 [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:bg-transparent [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:px-3 [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:py-1 [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:shadow-none [&>[data-slot=autocomplete]>[data-slot=autocomplete-input]]:focus-visible:ring-0",
        "[&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:h-full [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:rounded-none [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:border-0 [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:bg-transparent [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:px-3 [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:py-1 [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:shadow-none [&>[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:focus-visible:ring-0",
        "[&>[data-slot=combobox]>[data-slot=combobox-input]]:h-full [&>[data-slot=combobox]>[data-slot=combobox-input]]:rounded-none [&>[data-slot=combobox]>[data-slot=combobox-input]]:border-0 [&>[data-slot=combobox]>[data-slot=combobox-input]]:bg-transparent [&>[data-slot=combobox]>[data-slot=combobox-input]]:px-3 [&>[data-slot=combobox]>[data-slot=combobox-input]]:py-1 [&>[data-slot=combobox]>[data-slot=combobox-input]]:shadow-none [&>[data-slot=combobox]>[data-slot=combobox-input]]:focus-visible:ring-0",
        "[&>[data-slot=textarea]]:min-h-[5.5rem] [&>[data-slot=textarea]]:w-full [&>[data-slot=textarea]]:rounded-none [&>[data-slot=textarea]]:border-0 [&>[data-slot=textarea]]:bg-transparent [&>[data-slot=textarea]]:px-3 [&>[data-slot=textarea]]:py-3 [&>[data-slot=textarea]]:shadow-none [&>[data-slot=textarea]]:focus-visible:ring-0",
        "[&>[data-slot=select]]:min-w-0 [&>[data-slot=select]]:shrink-0 [&>[data-slot=select]_[data-slot=select-trigger]]:h-full [&>[data-slot=select]_[data-slot=select-trigger]]:rounded-none [&>[data-slot=select]_[data-slot=select-trigger]]:border-0 [&>[data-slot=select]_[data-slot=select-trigger]]:bg-transparent [&>[data-slot=select]_[data-slot=select-trigger]]:px-3 [&>[data-slot=select]_[data-slot=select-trigger]]:py-2 [&>[data-slot=select]_[data-slot=select-trigger]]:shadow-none [&>[data-slot=select]_[data-slot=select-trigger]]:focus-visible:ring-0",
        "[&>[data-slot=native-select-wrapper]]:min-w-0 [&>[data-slot=native-select-wrapper]]:shrink-0 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:h-full [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:rounded-none [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:border-0 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:bg-transparent [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:px-3 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:py-2 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:shadow-none [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:focus-visible:ring-0 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:pr-8 [&>[data-slot=native-select-wrapper]_.lucide-chevron-down]:right-3",
        "[&>[data-slot=button]]:h-6 [&>[data-slot=button]]:self-center [&>[data-slot=button]]:rounded-[calc(var(--radius)-5px)] [&>[data-slot=button]]:border-0 [&>[data-slot=button]]:px-2 [&>[data-slot=button]]:text-sm [&>[data-slot=button]]:shadow-none [&>[data-slot=button]]:focus-visible:ring-0 [&>[data-slot=button]:first-child]:ml-1.5 [&>[data-slot=button]:last-child]:mr-1.5",
        "[&>[data-slot=input-group-addon]_[data-slot=button]]:h-6 [&>[data-slot=input-group-addon]_[data-slot=button]]:rounded-[calc(var(--radius)-5px)] [&>[data-slot=input-group-addon]_[data-slot=button]]:border-0 [&>[data-slot=input-group-addon]_[data-slot=button]]:px-2 [&>[data-slot=input-group-addon]_[data-slot=button]]:text-sm [&>[data-slot=input-group-addon]_[data-slot=button]]:shadow-none [&>[data-slot=input-group-addon]_[data-slot=button]]:focus-visible:ring-0",
        "[&>[data-slot=input-group-addon][data-align=block-end]_[data-slot=button]]:h-8 [&>[data-slot=input-group-addon][data-align=block-end]_[data-slot=button]]:self-auto [&>[data-slot=input-group-addon][data-align=block-end]_[data-slot=button]]:px-3",
        assigns.class
      ])

    ~H"""
    <div
      data-slot="input-group"
      data-align={@align_attr}
      role="group"
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Text/icon/status/action segment used inside `input_group/1`.

  This is useful for prefixes, suffixes, inline status, and small utility
  content that should attach to the surrounding grouped field.

  ## Example

  ```heex title="Input group addon" align="full"
  <.input_group>
    <.input_group_addon>
      <.icon name="mail" class="size-4" />
    </.input_group_addon>
    <.input type="email" placeholder="team@example.com" />
  </.input_group>
  ```
  """)

  attr :align, :atom, default: :inline, values: [:inline, :block_end]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def input_group_addon(assigns) do
    assigns =
      assigns
      |> assign(:align_attr, if(assigns.align == :block_end, do: "block-end", else: "inline"))
      |> assign(:classes, [
        "inline-flex items-center gap-2 whitespace-nowrap bg-transparent",
        assigns.align == :inline && "has-[>[data-slot=button]]:-mx-1.5",
        assigns.align == :block_end && "whitespace-normal",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-group-addon" data-align={@align_attr} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Compact action button for use inside `input_group_addon/1`.

  This is intentionally smaller than the general `button/1` API. Use it for
  short text actions and icon-only utility actions embedded in an input group.

  ## Example

  ```heex title="Input group button" align="full"
  <.input_group>
    <.input placeholder="Search" />
    <.input_group_addon>
      <.input_group_button>Search</.input_group_button>
    </.input_group_addon>
  </.input_group>
  ```
  """)

  attr :variant, :atom,
    default: :ghost,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link]

  attr :size, :atom, default: :xs, values: [:xs, :icon_xs]
  attr :type, :string, default: "button"
  attr :class, :string, default: nil

  attr :rest, :global,
    include:
      ~w(disabled name value form id aria-label aria-expanded aria-controls aria-haspopup title)

  slot :inner_block, required: true

  def input_group_button(assigns) do
    assigns =
      assign(assigns, :classes, [
        "shadow-none focus-visible:ring-0",
        assigns.class
      ])

    ~H"""
    <CinderUI.Components.Actions.button
      variant={@variant}
      size={@size}
      type={@type}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </CinderUI.Components.Actions.button>
    """
  end

  doc("""
  Styled text segment for use inside `input_group_addon/1`.

  Use this for prefixes, suffixes, units, and short status text when the addon
  also contains icons or buttons.

  ## Example

  ```heex title="Input group text" align="full"
  <.input_group>
    <.input placeholder="Amount" />
    <.input_group_addon>
      <.input_group_text>USD</.input_group_text>
    </.input_group_addon>
  </.input_group>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def input_group_text(assigns) do
    assigns =
      assign(assigns, :classes, [
        "inline-flex items-center gap-2 whitespace-nowrap text-muted-foreground",
        "[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0",
        assigns.class
      ])

    ~H"""
    <span data-slot="input-group-text" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  doc("""
  Renders an OTP-style segmented input layout.

  This component renders one input per position and can be wired using standard
  Phoenix input names such as `code[]`. The bundled `CuiInputOtp` hook adds
  auto-advance, backspace-to-previous, and paste distribution behavior.

  ## Examples

  ```heex title="Basic OTP input" align="full"
  <.input_otp name="verification_code[]" length={6} />
  ```

  ```heex title="With grouped separators" align="full"
  <.input_otp name="backup_code[]" length={6} groups={[3, 3]} values={["1", "2", "3", "4", "5", "6"]} />
  ```

  ### With FormField (string value is split into individual cells)

      <.input_otp field={@form[:code]} length={6} />

  ### With label

      <.input_otp field={@form[:code]} label="Verification code" length={6} />

  ### With explicit errors

      <.input_otp field={@form[:code]} label="Verification code" errors={["is invalid"]} length={6} />

  ### Inside field composition

      <.field>
        <:label for={@form[:code].id}>Verification code</:label>
        <.input_otp field={@form[:code]} length={6} />
        <:description>Enter the 6-digit code from your email.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: "code[]"
  attr :length, :integer, default: 6
  attr :values, :list, default: []
  attr :groups, :list, default: []
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil
  attr :rest, :global

  def input_otp(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> then(fn a ->
        if is_binary(a[:value]) && a[:values] == [] do
          assign(a, :values, String.graphemes(a.value || ""))
        else
          a
        end
      end)
      |> assign(:id, assigns.id || "cinder-ui-input-otp-#{System.unique_integer([:positive])}")
      |> assign(:separator_indexes, input_otp_separator_indexes(assigns.groups, assigns.length))
      |> assign(:classes, [
        "flex items-center gap-2",
        assigns.class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <div id={@id} data-slot="input-otp" class={classes(@classes)} phx-hook="CuiInputOtp">
        <.input_otp_cell
          :for={index <- Enum.to_list(0..(@length - 1))}
          index={index}
          name={@name}
          value={Enum.at(@values, index, "")}
          input_class={@input_class}
          extra_attrs={@rest}
          show_separator={index in @separator_indexes}
        />
      </div>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <div
      :if={!@label && @errors == []}
      id={@id}
      data-slot="input-otp"
      class={classes(@classes)}
      phx-hook="CuiInputOtp"
    >
      <.input_otp_cell
        :for={index <- Enum.to_list(0..(@length - 1))}
        index={index}
        name={@name}
        value={Enum.at(@values, index, "")}
        input_class={@input_class}
        extra_attrs={@rest}
        show_separator={index in @separator_indexes}
      />
    </div>
    """
  end

  attr :index, :integer, required: true
  attr :name, :string, required: true
  attr :value, :string, default: ""
  attr :input_class, :string, default: nil
  attr :show_separator, :boolean, required: true
  attr :extra_attrs, :any, default: %{}

  defp input_otp_cell(assigns) do
    ~H"""
    <input
      data-input-otp-input
      data-input-otp-index={@index}
      type="text"
      inputmode="numeric"
      pattern="[0-9]*"
      maxlength="1"
      name={@name}
      value={@value}
      class={
        classes([
          "border-input focus-visible:border-ring focus-visible:ring-ring/50 h-10 w-10 rounded-md border bg-transparent text-center text-sm shadow-xs outline-none focus-visible:ring-[3px]",
          @input_class
        ])
      }
      {@extra_attrs}
    />
    <span
      :if={@show_separator}
      data-slot="input-otp-separator"
      data-input-otp-separator-after={@index}
      class="text-muted-foreground text-sm"
    >
      -
    </span>
    """
  end
end
