defmodule CinderUI.Components.Advanced.Sidebar do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  alias CinderUI.Components.DataDisplay
  alias CinderUI.Helpers
  alias CinderUI.Icons

  doc("""
  Phoenix-first sidebar shell for app layouts.

  This component is designed for LiveView and server-rendered Phoenix apps,
  rather than mirroring shadcn's React-only primitive structure. Use the
  `:header`, `:sidebar`, `:footer`, and `:main` slots as the primary API.
  `sidebar/1` and `sidebar_main/1` remain available as lower-level escape
  hatches when you need manual control.

  Use `default_open` for the default uncontrolled behavior. Pass `open` to let
  LiveView control the current state, and pair it with `toggle_event` if the
  built-in trigger should push a server event instead of toggling locally.

  By default the sidebar shell stretches to the viewport height. Set
  `full_screen={false}` when rendering inside a nested panel or container that
  already manages its own height.

  ## Examples

  ```heex title="Workspace shell" align="full" vrt
  <.sidebar_layout id="workspace-shell-sidebar" persist_key="docs:workspace-shell">
    <:header>
      <.sidebar_header>
        <button
          type="button"
          class="hover:bg-sidebar-accent hover:text-sidebar-accent-foreground flex w-full items-center gap-3 rounded-lg px-2 py-2 text-left transition-colors"
        >
          <div class="bg-sidebar-primary text-sidebar-primary-foreground flex size-8 items-center justify-center rounded-lg">
            <.icon name="briefcase-business" class="size-4" />
          </div>
          <div data-sidebar-label class="min-w-0 flex-1">
            <p class="truncate text-sm font-medium">Acme Inc</p>
            <p class="text-sidebar-foreground/70 truncate text-xs">Enterprise</p>
          </div>
          <div data-sidebar-label class="text-sidebar-foreground/70 flex flex-col">
            <.icon name="chevron-up" class="size-3" />
            <.icon name="chevron-down" class="size-3 -mt-1" />
          </div>
        </button>
      </.sidebar_header>
    </:header>

    <:sidebar>
      <.sidebar_group label="Platform">
        <.sidebar_item icon="square-play" current={true} collapsible={true} default_open={true}>
          Playground
          <:children>
            <.sidebar_item>History</.sidebar_item>
            <.sidebar_item>Starred</.sidebar_item>
            <.sidebar_item>Settings</.sidebar_item>
          </:children>
        </.sidebar_item>
        <.sidebar_item icon="bot">Models</.sidebar_item>
        <.sidebar_item icon="book-open">Documentation</.sidebar_item>
        <.sidebar_item icon="settings-2">Settings</.sidebar_item>
      </.sidebar_group>
    </:sidebar>

    <:footer>
      <.sidebar_footer>
        <.sidebar_profile_menu
          id="workspace-shell-profile-menu"
          name="shadcn"
          subtitle="m@example.com"
          avatar_src="example.png"
          avatar_alt="shadcn"
        >
          <:item icon="badge-check">Account</:item>
          <:item icon="credit-card">Billing</:item>
          <:item icon="bell">Notifications</:item>
          <:item icon="log-out" separator_before={true}>Log out</:item>
        </.sidebar_profile_menu>
      </.sidebar_footer>
    </:footer>

    <:main>
      <div class="space-y-4">
        <div class="flex h-7 items-center">
          <.sidebar_trigger />
        </div>
        <section class="rounded-xl border bg-card p-5">
          <div class="flex items-center justify-between gap-4">
            <div>
              <h3 class="text-sm font-semibold">Release readiness</h3>
              <p class="text-muted-foreground mt-1 text-sm">2 items need review before ship.</p>
            </div>
            <.button size={:sm}>Open queue</.button>
          </div>
        </section>
        <div class="grid gap-4 md:grid-cols-2">
          <section class="rounded-xl border bg-card p-4">
            <h3 class="text-sm font-semibold">Current focus</h3>
            <p class="text-muted-foreground mt-3 text-sm">
              Ship the refreshed component docs and tighten visual regression coverage.
            </p>
          </section>
          <section class="rounded-xl border bg-card p-4">
            <h3 class="text-sm font-semibold">This week</h3>
            <p class="text-muted-foreground mt-3 text-sm">
              Sidebar primitives, docs examples, and browser-driven QA.
            </p>
          </section>
        </div>
      </div>
    </:main>
  </.sidebar_layout>
  ```

  ```heex title="Collapsed by default" align="full"
  <.sidebar_layout id="collapsed-sidebar" default_open={false} full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Navigation</span>
      </.sidebar_header>
    </:header>

    <:sidebar>
      <.sidebar_group label="Navigation">
        <.sidebar_item icon="home" current={true}>Home</.sidebar_item>
        <.sidebar_item icon="inbox">Inbox</.sidebar_item>
        <.sidebar_item icon="settings">Settings</.sidebar_item>
      </.sidebar_group>
    </:sidebar>

    <:main>
      <div class="space-y-4">
        <div class="flex h-7 items-center">
          <.sidebar_trigger />
        </div>
        <div class="rounded-xl border bg-card p-4">
          <h3 class="text-sm font-semibold">Compact inset content</h3>
          <p class="text-muted-foreground mt-2 text-sm">
            Collapse the rail by default when the surrounding panel already provides context.
          </p>
        </div>
      </div>
    </:main>
  </.sidebar_layout>
  ```

  ```heex title="Server-controlled open state" align="full"
  <.sidebar_layout
    id="server-controlled-sidebar"
    open={false}
    toggle_event="sidebar:set_open"
    full_screen={false}
  >
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Workspace</span>
        <.sidebar_trigger />
      </.sidebar_header>
    </:header>

    <:sidebar>
      <.sidebar_group label="Workspace">
        <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
        <.sidebar_item icon="inbox">Approvals</.sidebar_item>
        <.sidebar_item icon="settings">Settings</.sidebar_item>
      </.sidebar_group>
    </:sidebar>

    <:main>
      <div class="space-y-4">
        <div class="rounded-xl border bg-card p-4">
          <h3 class="text-sm font-semibold">Sidebar state comes from LiveView assigns.</h3>
          <p class="text-muted-foreground mt-2 text-sm">
            The trigger pushes an event, but the shell stays collapsed until the server sends back `open={true}`.
          </p>
        </div>
        <div class="rounded-xl border border-dashed p-4 text-sm text-muted-foreground">
          Useful when a layout-level toggle also drives persistence, analytics, or permission-based nav changes.
        </div>
      </div>
    </:main>
  </.sidebar_layout>
  ```

  ```heex title="Internal scrolling in a nested panel" align="full"
  <div class="h-80 overflow-hidden rounded-xl border">
    <.sidebar_layout id="scrolling-sidebar" full_screen={false}>
      <:sidebar>
        <.sidebar_group label="Large section">
          <.sidebar_item :for={index <- 1..14} icon="folder-open">
            Project {index}
          </.sidebar_item>
        </.sidebar_group>
        <.sidebar_group label="Pinned">
          <.sidebar_item icon="star">Launch checklist</.sidebar_item>
          <.sidebar_item icon="clock-3">Weekly review</.sidebar_item>
        </.sidebar_group>
      </:sidebar>
      <:main>
        <div class="space-y-4">
          <div class="rounded-xl border bg-card p-4">
            <h3 class="text-sm font-semibold">Internal scrolling</h3>
            <p class="text-muted-foreground mt-2 text-sm">
              Constrain the parent height and the sidebar’s content region becomes internally scrollable.
            </p>
          </div>
          <div class="rounded-xl border border-dashed p-4 text-sm text-muted-foreground">
            This pattern works well for nested inspectors, settings panes, or workflow steps embedded in a larger page.
          </div>
        </div>
      </:main>
    </.sidebar_layout>
  </div>
  ```
  """)

  attr :id, :string, default: nil
  attr :open, :boolean, default: nil
  attr :default_open, :boolean, default: true
  attr :toggle_event, :string, default: nil
  attr :full_screen, :boolean, default: true
  attr :collapsible, :atom, default: :icon, values: [:icon, :none]
  attr :persist_key, :string, default: nil
  attr :sidebar_class, :string, default: nil
  attr :sidebar_content_class, :string, default: nil
  attr :main_class, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :header

  slot :sidebar, required: true do
    attr :class, :string
    attr :content_class, :string
  end

  slot :footer

  slot :main, required: true do
    attr :class, :string
  end

  def sidebar_layout(assigns) do
    id = assigns.id || "cinder-ui-sidebar-#{System.unique_integer([:positive])}"

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:state, sidebar_layout_state(assigns))
      |> assign(:controlled, is_boolean(assigns.open))
      |> assign(:classes, sidebar_layout_classes(assigns))

    ~H"""
    <div
      id={@id}
      data-slot="sidebar-layout"
      data-state={@state}
      data-sidebar-controlled={@controlled}
      data-sidebar-toggle-event={@toggle_event}
      data-collapsible={@collapsible}
      data-sidebar-persist-key={@persist_key}
      style="--cui-sidebar-width: 16rem; --cui-sidebar-width-icon: 3rem;"
      class={classes(@classes)}
      phx-hook="CuiSidebar"
      {@rest}
    >
      <%= for sidebar <- @sidebar do %>
        <aside
          data-slot="sidebar-panel"
          class={
            classes([
              "bg-sidebar text-sidebar-foreground border-sidebar-border min-h-0 border-r",
              @sidebar_class,
              Map.get(sidebar, :class)
            ])
          }
        >
          <div class="flex h-full min-h-0 flex-col overflow-hidden">
            <%= if @header != [] do %>
              {render_slot(@header)}
            <% end %>

            <div
              data-slot="sidebar-content"
              class={
                classes([
                  "flex min-h-0 flex-1 flex-col gap-2 overflow-y-auto px-2 pb-2",
                  @sidebar_content_class,
                  Map.get(sidebar, :content_class)
                ])
              }
            >
              {render_slot(sidebar)}
            </div>

            <%= if @footer != [] do %>
              {render_slot(@footer)}
            <% end %>
          </div>
        </aside>
      <% end %>

      <%= for main <- @main do %>
        <main
          data-slot="sidebar-main"
          class={
            classes([
              "bg-background text-foreground min-h-0 min-w-0 p-4 md:p-6",
              @main_class,
              Map.get(main, :class)
            ])
          }
        >
          {render_slot(main)}
        </main>
      <% end %>
    </div>
    """
  end

  defp sidebar_layout_state(%{open: open}) when is_boolean(open) do
    if open, do: "expanded", else: "collapsed"
  end

  defp sidebar_layout_state(%{default_open: true}), do: "expanded"
  defp sidebar_layout_state(_assigns), do: "collapsed"

  defp sidebar_layout_classes(assigns) do
    [
      "group/sidebar grid w-full grid-cols-1 transition-[grid-template-columns] duration-200 md:grid-cols-[var(--cui-sidebar-width)_minmax(0,1fr)]",
      sidebar_layout_height_class(assigns.full_screen),
      sidebar_layout_collapsible_class(assigns.collapsible),
      assigns.class
    ]
  end

  defp sidebar_layout_height_class(true), do: "min-h-screen"
  defp sidebar_layout_height_class(false), do: "h-full min-h-0"

  defp sidebar_layout_collapsible_class(:icon) do
    "data-[state=collapsed]:md:grid-cols-[var(--cui-sidebar-width-icon)_minmax(0,1fr)] data-[state=collapsed]:[&_[data-sidebar-label]]:hidden"
  end

  defp sidebar_layout_collapsible_class(_collapsible), do: nil

  doc("""
  Sidebar panel region.

  This is the left-hand sidebar itself. Use it inside `sidebar_layout/1`.

  ## Example

  ```heex title="Sidebar panel" align="full"
  <div class="h-64 overflow-hidden rounded-xl border">
    <.sidebar class="h-full">
      <:header>
        <.sidebar_header>
          <span data-sidebar-label class="text-sm font-semibold">Workspace</span>
        </.sidebar_header>
      </:header>

      <.sidebar_group label="Navigation">
        <.sidebar_item icon="home" current={true}>Home</.sidebar_item>
        <.sidebar_item icon="folder">Projects</.sidebar_item>
      </.sidebar_group>

      <:footer>
        <.sidebar_footer>
          <span class="text-sidebar-foreground/70 text-xs">Low-level panel helper</span>
        </.sidebar_footer>
      </:footer>
    </.sidebar>
  </div>
  ```
  """)

  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  attr :rest, :global
  slot :header
  slot :footer
  slot :inner_block

  def sidebar(assigns) do
    assigns =
      assigns
      |> assign(:classes, [
        "bg-sidebar text-sidebar-foreground border-sidebar-border min-h-0 border-r",
        assigns.class
      ])
      |> assign(:panel_classes, ["flex h-full min-h-0 flex-col overflow-hidden"])
      |> assign(:content_classes, [
        "flex min-h-0 flex-1 flex-col gap-2 overflow-y-auto px-2 pb-2",
        assigns.content_class
      ])

    ~H"""
    <aside data-slot="sidebar-panel" class={classes(@classes)} {@rest}>
      <div class={classes(@panel_classes)}>
        <%= if @header != [] do %>
          {render_slot(@header)}
        <% end %>

        <div data-slot="sidebar-content" class={classes(@content_classes)}>
          {render_slot(@inner_block)}
        </div>

        <%= if @footer != [] do %>
          {render_slot(@footer)}
        <% end %>
      </div>
    </aside>
    """
  end

  doc("""
  Sidebar sibling content region.

  Use this inside `sidebar_layout/1` for the main page content that sits beside
  the sidebar.

  ## Example

  ```heex title="Sidebar main" align="full"
  <div class="overflow-hidden rounded-xl border">
    <.sidebar_main class="space-y-4">
      <div class="rounded border bg-card p-4 text-sm">Content area</div>
      <div class="rounded border border-dashed p-4 text-sm text-muted-foreground">
        Use the lower-level helper when you want manual control over the main region wrapper.
      </div>
    </.sidebar_main>
  </div>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_main(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-background text-foreground min-h-0 min-w-0 p-4 md:p-6",
        assigns.class
      ])

    ~H"""
    <main data-slot="sidebar-main" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </main>
    """
  end

  doc("""
  Sidebar header container.

  Use this inside the `:header` slot of `sidebar_layout/1` for branding,
  workspace selectors, or the collapse trigger.

  ## Example

  ```heex title="Sidebar header" align="full"
  <.sidebar_layout id="sidebar-header-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <div data-sidebar-label class="min-w-0 flex-1">
          <p class="truncate text-sm font-semibold">Workspace</p>
          <p class="text-sidebar-foreground/70 truncate text-xs">Active release branch</p>
        </div>
        <.badge variant={:outline}>3 open</.badge>
      </.sidebar_header>
    </:header>
    <:sidebar>
      <.sidebar_group label="Navigation">
        <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:main><div class="rounded border bg-card p-4 text-sm">Inset</div></:main>
  </.sidebar_layout>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_header(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-sidebar sticky top-0 z-10 flex min-h-12 items-center gap-2 px-2 py-2",
        assigns.class
      ])

    ~H"""
    <header data-slot="sidebar-header" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </header>
    """
  end

  doc("""
  Sidebar footer container.

  Use this inside the `:footer` slot of `sidebar_layout/1` for profile,
  workspace status, or secondary actions anchored at the bottom.

  ## Example

  ```heex title="Sidebar footer" align="full"
  <.sidebar_layout id="sidebar-footer-example" full_screen={false}>
    <:sidebar>
      <.sidebar_group label="Workspace">
        <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
        <.sidebar_item icon="activity">Metrics</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:footer>
      <.sidebar_footer>
        <.sidebar_profile_menu
          id="sidebar-footer-profile"
          name="Levi Buzolic"
          subtitle="levi@example.com"
          avatar_src="example.png"
          avatar_alt="Levi Buzolic"
        >
          <:item icon="user">Account</:item>
          <:item icon="settings">Preferences</:item>
          <:item icon="log-out" separator_before={true}>Log out</:item>
        </.sidebar_profile_menu>
      </.sidebar_footer>
    </:footer>
    <:main><div class="rounded border bg-card p-4 text-sm">Inset</div></:main>
  </.sidebar_layout>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_footer(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-sidebar sticky bottom-0 z-10 mt-auto flex min-h-12 items-center gap-2 px-2 py-2",
        assigns.class
      ])

    ~H"""
    <footer data-slot="sidebar-footer" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </footer>
    """
  end

  doc("""
  Profile/account menu pattern for sidebar footers.

  This composes the sidebar footer trigger with an avatar, identity copy, and a
  dropdown menu for account actions. It is intended for the common "current
  user in the sidebar footer" pattern.

  ## Examples

  ```heex title="Sidebar profile menu" align="full"
  <.sidebar_layout id="sidebar-profile-menu-shell" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Workspace tools</span>
      </.sidebar_header>
    </:header>
    <:sidebar>
      <.sidebar_group label="Navigation">
        <.sidebar_item icon="settings">Settings</.sidebar_item>
        <.sidebar_item icon="circle-help">Get help</.sidebar_item>
        <.sidebar_item icon="search">Search</.sidebar_item>
      </.sidebar_group>
      <.sidebar_group label="Shortcuts">
        <.sidebar_item icon="command">Command palette</.sidebar_item>
        <.sidebar_item icon="bell">Notifications</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:footer>
      <.sidebar_footer>
        <.sidebar_profile_menu
          id="sidebar-profile-menu-example"
          name="shadcn"
          subtitle="m@example.com"
          avatar_src="example.png"
          avatar_alt="shadcn"
        >
          <:item icon="badge-check">Account</:item>
          <:item icon="credit-card">Billing</:item>
          <:item icon="bell">Notifications</:item>
          <:item icon="log-out" separator_before={true}>Log out</:item>
        </.sidebar_profile_menu>
      </.sidebar_footer>
    </:footer>
    <:main><div class="rounded border bg-card p-4 text-sm">Inset</div></:main>
  </.sidebar_layout>
  ```

  ```heex title="Collapsed profile menu" align="full"
  <.sidebar_layout id="sidebar-profile-menu-collapsed" default_open={false} full_screen={false}>
    <:sidebar>
      <.sidebar_group label="Quick actions">
        <.sidebar_item icon="home" current={true}>Home</.sidebar_item>
        <.sidebar_item icon="inbox">Inbox</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:footer>
      <.sidebar_footer>
        <.sidebar_profile_menu
          id="sidebar-profile-menu-collapsed-example"
          name="Mira Chen"
          subtitle="mira@example.com"
          avatar_src="example.png"
          avatar_alt="Mira Chen"
        >
          <:item icon="user">Profile</:item>
          <:item icon="settings">Settings</:item>
        </.sidebar_profile_menu>
      </.sidebar_footer>
    </:footer>
    <:main><div class="rounded border bg-card p-4 text-sm">Inset</div></:main>
  </.sidebar_layout>
  ```
  """)

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :subtitle, :string, default: nil, doc: "secondary line shown under the profile name"
  attr :avatar_src, :string, default: nil, doc: "avatar image URL for the trigger and menu header"
  attr :avatar_alt, :string, default: nil, doc: "accessible alt text for the avatar image"

  attr :avatar_fallback, :string,
    default: nil,
    doc: "fallback initials or text when no avatar image is available"

  attr :class, :string, default: nil

  attr :trigger_class, :string,
    default: nil,
    doc: "additional classes for the profile button trigger"

  attr :content_class, :string,
    default: nil,
    doc: "additional classes for the dropdown content panel"

  attr :rest, :global

  slot :item, required: true do
    attr :href, :string, doc: "standard anchor destination for external or full-page navigation"
    attr :navigate, :string, doc: "LiveView navigate target for a client-side redirect"
    attr :patch, :string, doc: "LiveView patch target for in-place URL/state updates"

    attr :method, :string,
      doc: "HTTP method forwarded to `Phoenix.Component.link/1` for non-GET actions"

    attr :replace, :boolean,
      doc: "replaces the current history entry instead of pushing a new one"

    attr :csrf_token, :string, doc: "explicit CSRF token for method-based links when needed"
    attr :disabled, :boolean, doc: "renders the item in a disabled, non-interactive state"
    attr :icon, :string, doc: "optional leading icon name rendered with the menu label"
    attr :separator_before, :boolean, doc: "inserts a divider before this item"
  end

  def sidebar_profile_menu(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative w-full", assigns.class])
      |> assign(:trigger_classes, [
        "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground ring-sidebar-ring flex w-full min-w-0 items-center gap-3 rounded-lg px-2 py-2 text-left outline-none transition-colors focus-visible:ring-2",
        "group-data-[state=collapsed]/sidebar:mx-auto group-data-[state=collapsed]/sidebar:size-8 group-data-[state=collapsed]/sidebar:justify-center group-data-[state=collapsed]/sidebar:px-0",
        assigns.trigger_class
      ])
      |> assign(:content_classes, [
        "bg-popover text-popover-foreground absolute right-0 bottom-full z-50 mb-2 hidden min-w-56 overflow-hidden rounded-lg border p-1 shadow-md",
        assigns.content_class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="sidebar-profile-menu"
      class={classes(@classes)}
      phx-hook="CuiDropdownMenu"
      {@rest}
    >
      <button
        type="button"
        data-dropdown-trigger
        class={classes(@trigger_classes)}
      >
        <DataDisplay.avatar
          src={@avatar_src}
          alt={@avatar_alt || @name}
          fallback={@avatar_fallback}
          class="size-8"
        />
        <div data-sidebar-label class="min-w-0 flex-1">
          <p class="truncate text-sm font-medium">{@name}</p>
          <p :if={@subtitle} class="text-sidebar-foreground/70 truncate text-xs">{@subtitle}</p>
        </div>
        <div data-sidebar-label class="text-sidebar-foreground/70 shrink-0">
          <Icons.icon name="ellipsis-vertical" class="size-4" />
        </div>
      </button>

      <div
        data-dropdown-content
        data-slot="dropdown-menu-content"
        role="menu"
        class={classes(@content_classes)}
      >
        <div class="border-b px-2 py-2.5">
          <div class="flex items-center gap-3">
            <DataDisplay.avatar
              src={@avatar_src}
              alt={@avatar_alt || @name}
              fallback={@avatar_fallback}
            />
            <div class="min-w-0 flex-1">
              <p class="truncate text-sm font-medium">{@name}</p>
              <p :if={@subtitle} class="text-muted-foreground truncate text-xs">{@subtitle}</p>
            </div>
          </div>
        </div>

        <div class="p-1">
          <%= for item <- @item do %>
            <div :if={item[:separator_before]} class="bg-border -mx-1 my-1 h-px" />
            <.sidebar_profile_menu_item item={item} />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp sidebar_profile_menu_item(assigns) do
    ~H"""
    <Helpers.action_item
      item={@item}
      role="menuitem"
      data_slot="dropdown-menu-item"
      class="hover:bg-accent hover:text-accent-foreground flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-sm outline-none"
    >
      <Icons.icon
        :if={@item[:icon]}
        name={@item[:icon]}
        class="size-4 shrink-0 text-muted-foreground"
      />
      <span class="truncate">{render_slot(@item)}</span>
    </Helpers.action_item>
    """
  end

  doc("""
  Sidebar group wrapper.

  Groups are useful for labeled sections such as navigation, tools, or account
  controls. Pass `label` for the section heading and render `sidebar_item/1`
  children directly inside the group.

  ## Example

  ```heex title="Sidebar group" align="full"
  <.sidebar_layout id="sidebar-group-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Product nav</span>
      </.sidebar_header>
    </:header>
    <:sidebar>
      <.sidebar_group label="Workspace">
        <.sidebar_item icon="folder-kanban" current={true} collapsible={true} default_open={true}>
          Projects
          <:children>
            <.sidebar_item>Roadmap</.sidebar_item>
            <.sidebar_item>Releases</.sidebar_item>
          </:children>
        </.sidebar_item>
        <.sidebar_item icon="ship-wheel" badge="2">Deployments</.sidebar_item>
        <.sidebar_item icon="message-square">Feedback</.sidebar_item>
      </.sidebar_group>

      <.sidebar_group label="Insights">
        <.sidebar_item icon="chart-column">Analytics</.sidebar_item>
        <.sidebar_item icon="bell-ring" badge="4">Alerts</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:main>
      <div class="rounded border bg-card p-4 text-sm">
        A sidebar can stack multiple labeled groups while keeping each section
        visually separate.
      </div>
    </:main>
  </.sidebar_layout>
  ```
  """)

  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :label_class, :string, default: nil
  attr :rest, :global
  slot :action
  slot :inner_block, required: true

  def sidebar_group(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative flex w-full min-w-0 flex-col gap-1", assigns.class])
      |> assign(:label_classes, [
        "text-sidebar-foreground/70 flex h-8 items-center px-2 text-xs font-medium",
        "group-data-[state=collapsed]/sidebar:-mt-8 group-data-[state=collapsed]/sidebar:opacity-0",
        assigns.label_class
      ])

    ~H"""
    <section data-slot="sidebar-group" class={classes(@classes)} {@rest}>
      <div :if={@label || @action != []} class="flex items-center gap-2">
        <div data-sidebar-label class={classes(@label_classes)}>{@label}</div>
        <div :if={@action != []} data-sidebar-label class="ml-auto pr-2">
          {render_slot(@action)}
        </div>
      </div>
      <div data-slot="sidebar-group-items" class="space-y-1">
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  doc("""
  Sidebar navigation item.

  Use this inside `sidebar_group/1` for app routes, navigation rows, and
  nested secondary items.

  ## Examples

  ```heex title="Sidebar item" align="full"
  <.sidebar_group label="Navigation">
    <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
    <.sidebar_item icon="inbox">Inbox</.sidebar_item>
  </.sidebar_group>
  ```

  ```heex title="Collapsible nested items" align="full"
  <.sidebar_group label="Workspace">
    <.sidebar_item icon="folder-kanban" collapsible={true} default_open={true}>
      Docs
      <:children>
        <.sidebar_item>Getting started</.sidebar_item>
        <.sidebar_item>Components</.sidebar_item>
      </:children>
    </.sidebar_item>
    <.sidebar_item icon="ship-wheel" href="#deployments" badge="3">
      Deployments
    </.sidebar_item>
  </.sidebar_group>
  ```
  """)

  attr :navigate, :string, default: nil, doc: "LiveView navigate target for the item"
  attr :patch, :string, default: nil, doc: "LiveView patch target for the item"

  attr :href, :string,
    default: nil,
    doc: "plain link destination when not using LiveView navigation"

  attr :method, :string,
    default: nil,
    doc: "HTTP method used when the item renders through `Phoenix.Component.link/1`"

  attr :replace, :boolean,
    default: false,
    doc: "replaces browser history instead of pushing a new entry"

  attr :csrf_token, :string,
    default: nil,
    doc: "explicit CSRF token for method-based sidebar links"

  attr :icon, :string, default: nil, doc: "leading icon rendered before the label"
  attr :badge, :string, default: nil, doc: "compact badge shown at the end of the row"

  attr :current, :boolean,
    default: false,
    doc: "marks the item as the current page for styling and `aria-current`"

  attr :collapsible, :boolean,
    default: false,
    doc: "renders the item as a disclosure that shows nested children"

  attr :default_open, :boolean,
    default: false,
    doc: "initial open state when `collapsible` is enabled"

  attr :disabled, :boolean,
    default: false,
    doc: "renders the item in a disabled, non-interactive state"

  attr :class, :string, default: nil
  attr :rest, :global
  slot :trailing
  slot :children
  slot :inner_block, required: true

  def sidebar_item(assigns) do
    assigns =
      assigns
      |> assign(:row_classes, [
        "ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground flex h-8 w-full min-w-0 items-center gap-2 rounded-md px-2 text-left text-sm text-sidebar-foreground outline-none transition-colors focus-visible:ring-2 active:bg-sidebar-accent active:text-sidebar-accent-foreground",
        "group-data-[state=collapsed]/sidebar:mx-auto group-data-[state=collapsed]/sidebar:size-8 group-data-[state=collapsed]/sidebar:justify-center group-data-[state=collapsed]/sidebar:px-0",
        assigns.current && "bg-sidebar-accent text-sidebar-accent-foreground font-medium",
        assigns.disabled && "pointer-events-none opacity-50",
        assigns.class
      ])
      |> assign(:children_classes, [
        "mt-1 ml-4 space-y-1 border-l border-sidebar-border pl-2",
        "group-data-[state=collapsed]/sidebar:hidden",
        "[&_[data-slot=sidebar-item-link]]:h-7 [&_[data-slot=sidebar-item-link]]:text-sidebar-foreground/80",
        "[&_[data-slot=sidebar-item-button]]:h-7 [&_[data-slot=sidebar-item-button]]:text-sidebar-foreground/80"
      ])

    ~H"""
    <div data-slot="sidebar-item">
      <%= if @collapsible and @children != [] do %>
        <details
          data-slot="sidebar-item-disclosure"
          class="group/sidebar-disclosure"
          open={@default_open}
        >
          <summary
            data-slot="sidebar-item-button"
            class={
              classes([
                @row_classes,
                "cursor-pointer list-none [&::-webkit-details-marker]:hidden"
              ])
            }
          >
            <.sidebar_item_inner
              icon={@icon}
              badge={@badge}
              trailing={@trailing}
              collapsible={true}
            >
              {render_slot(@inner_block)}
            </.sidebar_item_inner>
          </summary>
          <div data-slot="sidebar-item-children" class={classes(@children_classes)}>
            {render_slot(@children)}
          </div>
        </details>
      <% else %>
        <%= cond do %>
          <% @navigate -> %>
            <.link
              navigate={@navigate}
              aria-current={if(@current, do: "page", else: nil)}
              data-slot="sidebar-item-link"
              class={classes(@row_classes)}
              {@rest}
            >
              <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
                {render_slot(@inner_block)}
              </.sidebar_item_inner>
            </.link>
          <% @patch -> %>
            <.link
              patch={@patch}
              aria-current={if(@current, do: "page", else: nil)}
              data-slot="sidebar-item-link"
              class={classes(@row_classes)}
              {@rest}
            >
              <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
                {render_slot(@inner_block)}
              </.sidebar_item_inner>
            </.link>
          <% @href -> %>
            <.link
              href={@href}
              aria-current={if(@current, do: "page", else: nil)}
              aria-disabled={if(@disabled, do: "true", else: nil)}
              data-slot="sidebar-item-link"
              class={classes(@row_classes)}
              {@rest}
            >
              <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
                {render_slot(@inner_block)}
              </.sidebar_item_inner>
            </.link>
          <% true -> %>
            <.link
              href={if(@disabled, do: nil, else: "#")}
              aria-disabled={if(@disabled, do: "true", else: nil)}
              data-slot="sidebar-item-link"
              class={classes(@row_classes)}
              {@rest}
            >
              <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
                {render_slot(@inner_block)}
              </.sidebar_item_inner>
            </.link>
        <% end %>
      <% end %>
    </div>
    """
  end

  attr :icon, :string, default: nil
  attr :badge, :string, default: nil
  attr :trailing, :any, default: []
  attr :collapsible, :boolean, default: false
  slot :inner_block, required: true

  defp sidebar_item_inner(assigns) do
    ~H"""
    <%= if @icon do %>
      <Icons.icon name={@icon} class="size-4 shrink-0" aria-hidden="true" />
    <% end %>
    <span data-sidebar-label class="min-w-0 flex-1 truncate">
      {render_slot(@inner_block)}
    </span>
    <span
      :if={@badge}
      data-sidebar-label
      class="bg-sidebar-primary/15 text-sidebar-primary ml-auto flex h-5 min-w-5 items-center justify-center rounded-md px-1 text-[11px] font-medium tabular-nums"
    >
      {@badge}
    </span>
    <span :if={@trailing != []} data-sidebar-label class="text-sidebar-foreground/70 ml-auto shrink-0">
      {render_slot(@trailing)}
    </span>
    <span
      :if={@collapsible}
      data-sidebar-label
      class="text-sidebar-foreground/70 ml-auto shrink-0 transition-transform group-open/sidebar-disclosure:rotate-90"
    >
      <Icons.icon name="chevron-right" class="size-3.5" />
    </span>
    """
  end

  doc("""
  Button that toggles the surrounding `sidebar_layout/1` between expanded and collapsed.

  By default this renders the compact shadcn-style icon button. You can also
  supply your own trigger content or change the rendered tag with `as`.

  ## Example

  ```heex title="Sidebar trigger" align="full"
  <.sidebar_layout id="sidebar-trigger-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Navigation</span>
        <.sidebar_trigger />
      </.sidebar_header>
    </:header>
    <:sidebar>
      <.sidebar_group label="Navigation">
        <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
        <.sidebar_item icon="box">Releases</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:main><div class="rounded border bg-card p-4 text-sm">Inset</div></:main>
  </.sidebar_layout>
  ```

  ```heex title="Custom trigger content" align="full"
  <.sidebar_layout id="sidebar-trigger-custom-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Workspace</span>
        <.sidebar_trigger as="div" class="gap-2 px-2 text-xs">
          <.icon name="panel-left" class="size-4" />
          <span data-sidebar-label>Collapse</span>
        </.sidebar_trigger>
      </.sidebar_header>
    </:header>
    <:sidebar>
      <.sidebar_group label="Workspace">
        <.sidebar_item icon="folder">Projects</.sidebar_item>
        <.sidebar_item icon="users">Team</.sidebar_item>
      </.sidebar_group>
    </:sidebar>
    <:main><div class="rounded border bg-card p-4 text-sm">Inset</div></:main>
  </.sidebar_layout>
  ```
  """)

  attr :as, :string, default: "button"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: false

  def sidebar_trigger(assigns) do
    rest =
      cond do
        assigns.as == "button" and
          not Map.has_key?(assigns.rest, :type) and
            not Map.has_key?(assigns.rest, "type") ->
          Map.put(assigns.rest, :type, "button")

        assigns.as != "button" ->
          assigns.rest
          |> maybe_put_global_attr(:role, "button")
          |> maybe_put_global_attr(:tabindex, "0")

        true ->
          assigns.rest
      end

    assigns =
      assigns
      |> assign(:rest, rest)
      |> assign(:classes, [
        "ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground inline-flex size-7 items-center justify-center rounded-md text-sidebar-foreground outline-none transition-colors focus-visible:ring-2 active:bg-sidebar-accent",
        assigns.class
      ])

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      data-slot="sidebar-trigger"
      data-sidebar-trigger
      aria-label="Toggle sidebar"
      class={classes(@classes)}
      {@rest}
    >
      <%= if @inner_block == [] do %>
        <Icons.icon
          name="panel-left"
          aria-hidden="true"
          class="size-4"
        />
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </.dynamic_tag>
    """
  end

  defp maybe_put_global_attr(attrs, key, value) do
    string_key = Atom.to_string(key)

    if Map.has_key?(attrs, key) or Map.has_key?(attrs, string_key) do
      attrs
    else
      Map.put(attrs, key, value)
    end
  end
end
