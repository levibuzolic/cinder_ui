defmodule CinderUI.Components.Overlay do
  @moduledoc """
  Overlay and popup components.

  Included:

  - `dialog/1`
  - `alert_dialog/1`
  - `drawer/1`
  - `sheet/1`
  - `popover/1`
  - `tooltip/1`
  - `hover_card/1`
  - `dropdown_menu/1`
  - `menubar/1`

  Components requiring toggled visibility expose `data-*` attributes and optional
  LiveView hooks installed by `mix cinder_ui.install`.
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  doc("""
  Modal dialog with trigger/content slots.

  Set `open` from LiveView assigns for server-controlled state, or rely on the
  optional `CuiDialog` JS hook for client toggling.

  ## Examples

  ```heex title="Basic confirmation dialog"
  <.dialog id="delete-project-dialog">
    <:trigger>
      <.button variant={:destructive}>Delete project</.button>
    </:trigger>
    <:title>Delete project?</:title>
    <:description>This action cannot be undone.</:description>
    Are you sure you want to permanently remove this project?
    <:footer>
      <.button variant={:outline} type="button">Cancel</.button>
      <.button variant={:destructive} type="button">Delete</.button>
    </:footer>
  </.dialog>
  ```

  ```heex title="Form inside dialog"
  <.dialog id="invite-member-dialog">
    <:trigger><.button>Invite member</.button></:trigger>
    <:title>Invite teammate</:title>
    <:description>Grant access to this workspace.</:description>

    <div class="grid gap-4">
      <.field>
        <:label><.label for="invite_email">Email</.label></:label>
        <.input id="invite_email" type="email" placeholder="dev@company.com" />
      </.field>
      <.field>
        <:label><.label for="invite_role">Role</.label></:label>
        <.select id="invite_role" name="invite_role" value="member">
          <:option value="member" label="Member" />
          <:option value="admin" label="Admin" />
        </.select>
      </.field>
    </div>

    <:footer>
      <.button variant={:outline} type="button">Cancel</.button>
      <.button type="button">Send invite</.button>
    </:footer>
  </.dialog>
  ```

  ```heex title="Server-controlled open state"
  <.dialog id="billing-dialog" open={@show_billing}>
    <:trigger><.button>Open billing</.button></:trigger>
    <:title>Billing details</:title>
    <:description>Review your subscription and payment method.</:description>
    <p class="text-sm">Current plan: Pro</p>
  </.dialog>
  ```
  """)

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  slot :trigger, required: true
  slot :title
  slot :description
  slot :inner_block, required: true
  slot :footer

  def dialog(assigns) do
    assigns =
      assigns
      |> assign(:root_classes, ["relative", assigns.class])
      |> assign(:overlay_classes, [
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        !assigns.open && "hidden"
      ])
      |> assign(:content_classes, [
        "bg-background data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 outline-none sm:max-w-lg",
        !assigns.open && "hidden",
        assigns.content_class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="dialog"
      data-state={if(@open, do: "open", else: "closed")}
      class={classes(@root_classes)}
      phx-hook="CuiDialog"
    >
      <div data-slot="dialog-trigger" data-dialog-trigger>{render_slot(@trigger)}</div>

      <div data-slot="dialog-overlay" data-dialog-overlay class={classes(@overlay_classes)} />

      <section
        data-slot="dialog-content"
        data-dialog-content
        role="dialog"
        aria-modal="true"
        tabindex="-1"
        class={classes(@content_classes)}
      >
        <header data-slot="dialog-header" class="flex flex-col gap-2 text-center sm:text-left">
          <h2 :if={@title != []} data-slot="dialog-title" class="text-lg leading-none font-semibold">
            {render_slot(@title)}
          </h2>
          <p
            :if={@description != []}
            data-slot="dialog-description"
            class="text-muted-foreground text-sm"
          >
            {render_slot(@description)}
          </p>
        </header>

        <div>{render_slot(@inner_block)}</div>

        <footer
          :if={@footer != []}
          data-slot="dialog-footer"
          class="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end"
        >
          {render_slot(@footer)}
        </footer>

        <button
          type="button"
          data-slot="dialog-close"
          data-dialog-close
          aria-label="Close"
          class="ring-offset-background focus:ring-ring data-[state=open]:bg-accent data-[state=open]:text-muted-foreground absolute top-4 right-4 rounded-xs opacity-70 transition-opacity hover:opacity-100 focus:ring-2 focus:ring-offset-2 focus:outline-hidden"
        >
          × <span class="sr-only">Close</span>
        </button>
      </section>
    </div>
    """
  end

  doc("""
  Destructive-style dialog variant used for irreversible confirmation actions.

  It delegates to `dialog/1` and applies destructive emphasis classes.
  """)

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :class, :string, default: nil
  slot :trigger, required: true
  slot :title
  slot :description
  slot :inner_block, required: true
  slot :footer

  def alert_dialog(assigns) do
    assigns =
      assign(assigns, :content_class, "ring-destructive/20 border-destructive/30")

    ~H"""
    <.dialog
      id={@id}
      open={@open}
      class={@class}
      content_class={@content_class}
    >
      <:trigger>{render_slot(@trigger)}</:trigger>
      <:title>{render_slot(@title)}</:title>
      <:description>{render_slot(@description)}</:description>
      {render_slot(@inner_block)}
      <:footer>{render_slot(@footer)}</:footer>
    </.dialog>
    """
  end

  doc("""
  Drawer panel component.

  `side` controls placement: `:top`, `:right`, `:bottom`, or `:left`.
  """)

  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :side, :atom, default: :right, values: [:top, :right, :bottom, :left]
  attr :class, :string, default: nil
  slot :trigger, required: true
  slot :title
  slot :description
  slot :inner_block, required: true
  slot :footer

  def drawer(assigns) do
    side_classes =
      case assigns.side do
        :top -> "inset-x-0 top-0 mb-24 max-h-[80vh] rounded-b-lg border-b"
        :right -> "inset-y-0 right-0 w-3/4 border-l sm:max-w-sm"
        :bottom -> "inset-x-0 bottom-0 mt-24 max-h-[80vh] rounded-t-lg border-t"
        :left -> "inset-y-0 left-0 w-3/4 border-r sm:max-w-sm"
      end

    assigns =
      assigns
      |> assign(:side_classes, side_classes)
      |> assign(:overlay_classes, [
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        !assigns.open && "hidden"
      ])
      |> assign(:content_classes, [
        "group/drawer-content bg-background fixed z-50 flex h-auto flex-col",
        side_classes,
        !assigns.open && "hidden",
        assigns.class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="drawer"
      data-state={if(@open, do: "open", else: "closed")}
      phx-hook="CuiDrawer"
    >
      <div data-slot="drawer-trigger" data-drawer-trigger>{render_slot(@trigger)}</div>

      <div data-slot="drawer-overlay" data-drawer-overlay class={classes(@overlay_classes)} />

      <section
        data-slot="drawer-content"
        data-drawer-content
        role="dialog"
        aria-modal="true"
        tabindex="-1"
        class={classes(@content_classes)}
      >
        <div :if={@side == :bottom} class="bg-muted mx-auto mt-4 h-2 w-[100px] shrink-0 rounded-full" />

        <header data-slot="drawer-header" class="flex flex-col gap-0.5 p-4 md:gap-1.5 md:text-left">
          <h2 :if={@title != []} data-slot="drawer-title" class="text-foreground font-semibold">
            {render_slot(@title)}
          </h2>
          <p
            :if={@description != []}
            data-slot="drawer-description"
            class="text-muted-foreground text-sm"
          >
            {render_slot(@description)}
          </p>
        </header>

        <div class="px-4">{render_slot(@inner_block)}</div>

        <footer :if={@footer != []} data-slot="drawer-footer" class="mt-auto flex flex-col gap-2 p-4">
          {render_slot(@footer)}
        </footer>
      </section>
    </div>
    """
  end

  doc("""
  Sheet alias for drawer behavior.

  This mirrors shadcn's `sheet` semantic naming.
  """)

  def sheet(assigns), do: drawer(assigns)

  doc("""
  Popover with trigger and content slots.

  Uses optional `CuiPopover` hook for click toggling.
  """)

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  slot :trigger, required: true
  slot :content, required: true

  def popover(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative inline-block", assigns.class])
      |> assign(:popover_classes, [
        "bg-popover text-popover-foreground z-50 mt-2 hidden w-72 origin-top rounded-md border p-4 shadow-md outline-hidden",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        assigns.content_class
      ])

    ~H"""
    <div id={@id} data-slot="popover" class={classes(@classes)} phx-hook="CuiPopover">
      <div data-slot="popover-trigger" data-popover-trigger>{render_slot(@trigger)}</div>
      <div data-slot="popover-content" data-popover-content class={classes(@popover_classes)}>
        {render_slot(@content)}
      </div>
    </div>
    """
  end

  doc("""
  Tooltip helper with hover/focus behavior.
  """)

  attr :text, :string, required: true
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  slot :inner_block, required: true

  def tooltip(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["group relative inline-flex", assigns.class])
      |> assign(:content_classes, [
        "pointer-events-none absolute -top-10 left-1/2 z-50 hidden -translate-x-1/2 rounded-md bg-foreground px-3 py-1.5 text-xs text-background group-hover:block group-focus-within:block",
        assigns.content_class
      ])

    ~H"""
    <span data-slot="tooltip" class={classes(@classes)}>
      {render_slot(@inner_block)}
      <span data-slot="tooltip-content" class={classes(@content_classes)}>{@text}</span>
    </span>
    """
  end

  doc("""
  Hover card with trigger and content slots.
  """)

  attr :class, :string, default: nil
  slot :trigger, required: true
  slot :content, required: true

  def hover_card(assigns) do
    assigns = assign(assigns, :classes, ["group relative inline-flex", assigns.class])

    ~H"""
    <div data-slot="hover-card" class={classes(@classes)}>
      <div data-slot="hover-card-trigger">{render_slot(@trigger)}</div>
      <div
        data-slot="hover-card-content"
        class="bg-popover text-popover-foreground absolute left-0 top-[calc(100%+8px)] z-50 hidden w-64 rounded-md border p-4 shadow-md outline-hidden group-hover:block"
      >
        {render_slot(@content)}
      </div>
    </div>
    """
  end

  doc("""
  Dropdown menu structure.

  Menu open/close behavior is provided by the optional `CuiDropdownMenu` hook.
  """)

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  slot :trigger, required: true

  slot :item, required: true do
    attr :href, :string
    attr :disabled, :boolean
  end

  def dropdown_menu(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative inline-block text-left", assigns.class])
      |> assign(:content_classes, [
        "bg-popover text-popover-foreground data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 absolute right-0 z-50 mt-2 hidden min-w-40 overflow-hidden rounded-md border p-1 shadow-md",
        assigns.content_class
      ])

    ~H"""
    <div id={@id} data-slot="dropdown-menu" class={classes(@classes)} phx-hook="CuiDropdownMenu">
      <div data-slot="dropdown-menu-trigger" data-dropdown-trigger>{render_slot(@trigger)}</div>
      <div data-slot="dropdown-menu-content" data-dropdown-content class={classes(@content_classes)}>
        <%= for item <- @item do %>
          <a
            :if={item[:href]}
            data-slot="dropdown-menu-item"
            href={item[:href]}
            class={
              classes([
                "relative flex w-full cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none hover:bg-accent hover:text-accent-foreground",
                item[:disabled] && "pointer-events-none opacity-50"
              ])
            }
          >
            {render_slot(item)}
          </a>

          <button
            :if={!item[:href]}
            type="button"
            data-slot="dropdown-menu-item"
            disabled={item[:disabled]}
            class={
              classes([
                "relative flex w-full cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none hover:bg-accent hover:text-accent-foreground disabled:pointer-events-none disabled:opacity-50",
                item[:disabled] && "pointer-events-none opacity-50"
              ])
            }
          >
            {render_slot(item)}
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  doc("""
  Menubar scaffold with dropdown-like triggers.

  This is a simplified semantic wrapper for desktop command menus.
  """)

  attr :class, :string, default: nil

  slot :menu, required: true do
    attr :label, :string, required: true
  end

  def menubar(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-background flex items-center gap-1 rounded-md border p-1",
        assigns.class
      ])

    ~H"""
    <div data-slot="menubar" class={classes(@classes)}>
      <div :for={menu <- @menu} data-slot="menubar-menu" class="relative group">
        <button
          type="button"
          data-slot="menubar-trigger"
          class="inline-flex h-8 items-center rounded-sm px-3 text-sm font-medium hover:bg-accent hover:text-accent-foreground"
        >
          {menu.label}
        </button>
        <div
          data-slot="menubar-content"
          class="bg-popover text-popover-foreground invisible absolute left-0 top-[calc(100%+4px)] z-50 min-w-40 rounded-md border p-1 opacity-0 shadow-md transition group-hover:visible group-hover:opacity-100"
        >
          {render_slot(menu)}
        </div>
      </div>
    </div>
    """
  end
end
