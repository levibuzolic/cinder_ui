defmodule CinderUI.Components.Advanced.Command do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  alias CinderUI.Icons
  alias Phoenix.HTML.Safe

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

  ```heex title="Grouped combobox" align="full" vrt
  <div class="pb-40">
    <.combobox
      id="timezone"
      placeholder="Select a timezone"
      open={true}
    >
      <:option value="new-york" label="(GMT-5) New York" group="Americas" />
      <:option value="london" label="(GMT+0) London" group="Europe" />
    </.combobox>
  </div>
  ```

  ```heex title="Custom combobox items" align="full" vrt
  <div class="pb-32">
    <.combobox
      id="framework"
      placeholder="Select a framework"
      open={true}
    >
      <:option value="next" label="Next.js">
        <span class="flex flex-col">
          <span class="font-medium">Next.js</span>
          <span class="text-muted-foreground text-xs">React framework</span>
        </span>
      </:option>
    </.combobox>
  </div>
  ```
  """)

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  attr :placeholder, :string, default: "Select an option"
  attr :value, :string, default: nil
  attr :open, :boolean, default: false
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
    attr :group, :string
  end

  def combobox(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative w-full", assigns.class])
      |> assign(:content_classes, [
        "bg-popover text-popover-foreground absolute z-50 mt-2 w-full rounded-md border p-1 shadow-md",
        if(assigns.open, do: "block", else: "hidden"),
        assigns.content_class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="combobox"
      data-state={if @open, do: "open", else: "closed"}
      class={classes(@classes)}
      phx-hook="CuiCombobox"
      {@rest}
    >
      <input
        data-slot="combobox-input"
        data-combobox-input
        value={@value}
        placeholder={@placeholder}
        autocomplete="off"
        role="combobox"
        aria-autocomplete="list"
        aria-controls={"#{@id}-content"}
        aria-expanded={@open}
        aria-activedescendant=""
        class="file:text-foreground placeholder:text-muted-foreground border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
      />
      <div
        id={"#{@id}-content"}
        data-slot="combobox-content"
        data-combobox-content
        role="listbox"
        tabindex="-1"
        class={classes(@content_classes)}
      >
        <div
          :for={group <- grouped_options(@option)}
          data-slot="combobox-group"
          data-combobox-group
          class={group.label && "py-1"}
        >
          <div
            :if={group.label}
            data-slot="combobox-group-label"
            class="text-muted-foreground px-2 py-1 text-xs font-medium"
          >
            {group.label}
          </div>

          <button
            :for={{option, index} <- group.options}
            id={"#{@id}-combobox-option-#{index}"}
            type="button"
            role="option"
            data-slot="combobox-item"
            data-value={option.value}
            data-label={option.label}
            data-selected={
              if @value == option.value || @value == option.label, do: "true", else: "false"
            }
            aria-selected={@value == option.value || @value == option.label}
            class={
              classes([
                "relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-left text-sm outline-hidden select-none data-[highlighted=true]:bg-accent data-[highlighted=true]:text-accent-foreground"
              ])
            }
          >
            <%= if slot_has_content?(option) do %>
              {render_slot(option)}
            <% else %>
              {option.label}
            <% end %>
            <span
              data-slot="select-check"
              class={
                classes([
                  "absolute right-2 flex size-3.5 items-center justify-center",
                  !(@value == option.value || @value == option.label) && "hidden"
                ])
              }
            >
              <Icons.icon name="check" class="size-4" aria-hidden="true" />
            </span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp grouped_options(options) do
    options
    |> Enum.with_index()
    |> Enum.chunk_by(fn {option, _index} -> Map.get(option, :group) end)
    |> Enum.map(fn group_options ->
      %{
        label: group_options |> List.first() |> elem(0) |> Map.get(:group),
        options: group_options
      }
    end)
  end

  defp slot_has_content?(%{inner_block: inner_block}) when is_function(inner_block, 2) do
    slot_content_present?(inner_block.(nil, nil))
  end

  defp slot_has_content?(%{inner_block: inner_block}) when is_function(inner_block, 1) do
    slot_content_present?(inner_block.(nil))
  end

  defp slot_has_content?(%{inner_block: inner_block}) when is_function(inner_block, 0) do
    slot_content_present?(inner_block.())
  end

  defp slot_has_content?(%{inner_block: inner_block}) do
    slot_content_present?(inner_block)
  end

  defp slot_has_content?(_slot), do: false

  defp slot_content_present?(content) do
    content
    |> slot_content_to_string()
    |> String.trim()
    |> then(&(&1 != ""))
  end

  defp slot_content_to_string(nil), do: ""

  defp slot_content_to_string(content) do
    content
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
