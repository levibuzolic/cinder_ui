defmodule CinderUI.Components.Advanced do
  @moduledoc """
  Higher-level components that map to shadcn patterns with progressive enhancement.

  Included:

  - `command/1`
  - `combobox/1`
  - `calendar/1`
  - `carousel/1`
  - `chart/1`
  - `sidebar/1`
  - `item/1`

  These components intentionally favor no-JS defaults and expose hooks/classes so
  advanced interactions can be layered in using LiveView hooks.
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

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
    <div data-slot="command" class={classes(@classes)}>
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

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def combobox(assigns) do
    assigns = assign(assigns, :classes, ["relative w-full", assigns.class])

    ~H"""
    <div id={@id} data-slot="combobox" class={classes(@classes)} phx-hook="CuiCombobox">
      <input
        data-slot="combobox-input"
        data-combobox-input
        value={@value}
        placeholder={@placeholder}
        class="file:text-foreground placeholder:text-muted-foreground border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
      />
      <div
        data-slot="combobox-content"
        data-combobox-content
        class="bg-popover text-popover-foreground absolute z-50 mt-2 hidden w-full rounded-md border p-1 shadow-md"
      >
        <button
          :for={option <- @option}
          type="button"
          data-slot="combobox-item"
          data-value={option.value}
          class={
            classes([
              "relative flex w-full cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none hover:bg-accent hover:text-accent-foreground",
              @value == option.value && "bg-accent text-accent-foreground"
            ])
          }
        >
          {option.label}
        </button>
      </div>
    </div>
    """
  end

  doc("""
  Calendar wrapper.

  This is a style container for integration with your date picker of choice.

  ## Example

  ```heex title="Calendar shell" align="full"
  <.calendar>
    <div class="grid grid-cols-7 gap-2 text-center text-sm">
      <span>1</span>
      <span>2</span>
      <span>3</span>
      <span>4</span>
      <span>5</span>
      <span>6</span>
      <span>7</span>
    </div>
  </.calendar>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def calendar(assigns) do
    assigns = assign(assigns, :classes, ["rounded-md border p-3", assigns.class])

    ~H"""
    <div data-slot="calendar" class={classes(@classes)}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Carousel shell.

  Render slides in `:item` slots and wire interactions with a LiveView hook or
  external script.

  ## Example

  ```heex title="Carousel" align="full"
  <.carousel id="feature-carousel">
    <:item><div class="rounded-md bg-muted p-8 text-sm">Slide one</div></:item>
    <:item><div class="rounded-md bg-muted/60 p-8 text-sm">Slide two</div></:item>
  </.carousel>
  ```
  """)

  attr :id, :string, required: true
  attr :class, :string, default: nil
  slot :item, required: true

  def carousel(assigns) do
    assigns = assign(assigns, :classes, ["relative", assigns.class])

    ~H"""
    <div id={@id} data-slot="carousel" class={classes(@classes)} phx-hook="CuiCarousel">
      <div data-slot="carousel-content" class="overflow-hidden">
        <div class="flex" data-carousel-track>
          <div
            :for={item <- @item}
            data-slot="carousel-item"
            class="min-w-0 shrink-0 grow-0 basis-full"
          >
            {render_slot(item)}
          </div>
        </div>
      </div>

      <button
        type="button"
        data-slot="carousel-previous"
        data-carousel-prev
        class="absolute left-2 top-1/2 -translate-y-1/2 rounded-full border bg-background p-2"
      >
        ←
      </button>
      <button
        type="button"
        data-slot="carousel-next"
        data-carousel-next
        class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full border bg-background p-2"
      >
        →
      </button>
    </div>
    """
  end

  doc("""
  Chart frame component for wrapping chart libraries with shadcn tokens.

  ## Example

  ```heex title="Chart shell" align="full"
  <.chart>
    <:title>Traffic</:title>
    <:description>Requests over the last 7 days.</:description>
    <div class="h-40 rounded-md bg-muted/60"></div>
  </.chart>
  ```
  """)

  attr :class, :string, default: nil
  slot :title
  slot :description
  slot :inner_block, required: true

  def chart(assigns) do
    assigns = assign(assigns, :classes, ["rounded-xl border bg-card p-4", assigns.class])

    ~H"""
    <section data-slot="chart" class={classes(@classes)}>
      <header :if={@title != [] or @description != []} class="mb-4">
        <h3 :if={@title != []} class="text-sm font-semibold">{render_slot(@title)}</h3>
        <p :if={@description != []} class="text-muted-foreground text-sm">
          {render_slot(@description)}
        </p>
      </header>
      <div data-slot="chart-content">{render_slot(@inner_block)}</div>
    </section>
    """
  end

  doc("""
  Sidebar layout shell.

  ## Example

  ```heex title="Sidebar layout" align="full"
  <.sidebar>
    <:rail>
      <div class="space-y-2 text-sm">
        <div>Overview</div>
        <div>Settings</div>
      </div>
    </:rail>
    <:inset>
      <div class="rounded bg-muted p-4 text-sm">Main content</div>
    </:inset>
  </.sidebar>
  ```
  """)

  attr :class, :string, default: nil
  slot :rail, required: true
  slot :inset, required: true

  def sidebar(assigns) do
    assigns =
      assign(assigns, :classes, ["grid min-h-screen md:grid-cols-[260px_1fr]", assigns.class])

    ~H"""
    <div data-slot="sidebar" class={classes(@classes)}>
      <aside data-slot="sidebar-rail" class="border-r bg-muted/20 p-4">{render_slot(@rail)}</aside>
      <main data-slot="sidebar-inset" class="min-w-0 p-6">{render_slot(@inset)}</main>
    </div>
    """
  end
end
