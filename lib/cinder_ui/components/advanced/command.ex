defmodule CinderUI.Components.Advanced.Command do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  alias CinderUI.Icons

  doc("""
  Command palette layout.

  This renders the shell of a command palette (`input + list + items`).

  ## Examples

  ```heex title="Command palette" align="full"
  <.command placeholder="Search commands...">
    <:group heading="General">
      <.item value="profile">Profile</.item>
      <.item value="billing">Billing</.item>
    </:group>

    <:group heading="Workspace">
      <.item value="settings">Settings</.item>
    </:group>
  </.command>
  ```

  ```heex title="Project switcher" align="full"
  <.command placeholder="Jump to project...">
    <:group heading="Projects">
      <.item value="docs">Docs site</.item>
      <.item value="demo">Demo app</.item>
    </:group>

    <:group heading="Teams">
      <.item value="platform">Platform team</.item>
    </:group>
  </.command>
  ```
  """)

  attr :class, :string, default: nil
  attr :placeholder, :string, default: "Type a command..."
  attr :rest, :global

  slot :group do
    attr :heading, :string
  end

  def command(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-popover text-popover-foreground flex h-full w-full flex-col overflow-hidden rounded-md border shadow-md",
        assigns.class
      ])

    ~H"""
    <div data-slot="command" class={classes(@classes)} {@rest}>
      <div data-slot="command-input-wrapper" class="flex items-center border-b px-3">
        <input
          data-slot="command-input"
          type="text"
          placeholder={@placeholder}
          class="flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground"
        />
      </div>

      <div data-slot="command-list" class="max-h-[300px] overflow-y-auto overflow-x-hidden p-1">
        <div
          :for={group <- @group}
          data-slot="command-group"
          class="overflow-hidden p-1 text-foreground"
        >
          <div
            :if={group[:heading]}
            data-slot="command-group-heading"
            class="text-muted-foreground px-2 py-1.5 text-xs font-medium"
          >
            {group.heading}
          </div>
          <div class="space-y-1">{render_slot(group)}</div>
        </div>
      </div>
    </div>
    """
  end

  doc("""
  Command/list item.

  ## Example

  ```heex title="Command item" align="full"
  <.command>
    <:group heading="General">
      <.item value="profile">Profile</.item>
    </:group>
  </.command>
  ```
  """)

  attr :class, :string, default: nil
  attr :value, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def item(assigns) do
    assigns =
      assign(assigns, :classes, [
        "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50 aria-selected:bg-accent aria-selected:text-accent-foreground",
        assigns.class
      ])

    ~H"""
    <div
      data-slot="item"
      role="option"
      data-value={@value}
      data-disabled={@disabled}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Combobox scaffold using an input and option list.

  It is intentionally unopinionated on state and filtering logic.

  ## When to use it

  Use `combobox/1` when you want a lightweight client-side filter input that
  writes the selected label back into the visible text field.

  Typing narrows the list and implicitly highlights the first visible match, so
  `Enter` can accept it without extra arrow-key navigation. `Escape` and
  clicking away restore the last committed value.

  Prefer `autocomplete/1` when the selected value needs to submit through a
  hidden input, when labels and values differ, or when the control participates
  in a larger form workflow.

  ## Example

  ```heex title="Combobox" align="full"
  <.combobox id="plan" value="Pro">
    <:option value="Free" label="Free" />
    <:option value="Pro" label="Pro" />
  </.combobox>
  ```
  """)

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :placeholder, :string, default: "Select an option"
  attr :value, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def combobox(assigns) do
    assigns = assign(assigns, :classes, ["relative w-full", assigns.class])

    ~H"""
    <div id={@id} data-slot="combobox" class={classes(@classes)} phx-hook="CuiCombobox" {@rest}>
      <input
        data-slot="combobox-input"
        data-combobox-input
        value={@value}
        placeholder={@placeholder}
        autocomplete="off"
        role="combobox"
        aria-autocomplete="list"
        aria-controls={"#{@id}-content"}
        aria-expanded="false"
        aria-activedescendant=""
        class="file:text-foreground placeholder:text-muted-foreground border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
      />
      <div
        id={"#{@id}-content"}
        data-slot="combobox-content"
        data-combobox-content
        role="listbox"
        tabindex="-1"
        class="bg-popover text-popover-foreground absolute z-50 mt-2 hidden w-full rounded-md border p-1 shadow-md"
      >
        <button
          :for={{option, index} <- Enum.with_index(@option)}
          id={"#{@id}-combobox-option-#{index}"}
          type="button"
          role="option"
          data-slot="combobox-item"
          data-value={option.value}
          data-selected={@value == option.value}
          aria-selected={@value == option.value}
          class={
            classes([
              "relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none data-[highlighted=true]:bg-accent data-[highlighted=true]:text-accent-foreground"
            ])
          }
        >
          {option.label}
          <span
            data-slot="select-check"
            class={
              classes([
                "absolute right-2 flex size-3.5 items-center justify-center",
                @value != option.value && "hidden"
              ])
            }
          >
            <Icons.icon name="check" class="size-4" aria-hidden="true" />
          </span>
        </button>
      </div>
    </div>
    """
  end
end
