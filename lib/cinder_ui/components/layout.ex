defmodule CinderUI.Components.Layout do
  @moduledoc """
  Layout and structural primitives inspired by shadcn/ui.

  Included:

  - Card family (`card/1`, `card_header/1`, `card_title/1`, `card_description/1`, `card_action/1`, `card_content/1`, `card_footer/1`)
  - `panel/1`
  - `separator/1`
  - `skeleton/1`
  - `aspect_ratio/1`
  - `kbd/1`
  - `kbd_group/1`
  - `typography/1`
  - `scroll_area/1`
  - `resizable/1` (in progress, not ready for use)

  [View live Layout examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#layout).
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  @typography_variants [
    h1: %{
      tag: "h1",
      classes: "scroll-m-20 text-4xl font-extrabold leading-tight text-balance lg:text-5xl"
    },
    h2: %{
      tag: "h2",
      classes: "scroll-m-20 border-b pb-2 text-3xl font-semibold leading-tight first:mt-0"
    },
    h3: %{tag: "h3", classes: "scroll-m-20 text-2xl font-semibold leading-snug"},
    h4: %{tag: "h4", classes: "scroll-m-20 text-xl font-semibold leading-snug"},
    p: %{tag: "p", classes: "leading-7 [&:not(:first-child)]:mt-6"},
    lead: %{tag: "p", classes: "text-muted-foreground text-xl leading-7"},
    large: %{tag: "div", classes: "text-lg font-semibold leading-7"},
    small: %{tag: "small", classes: "text-sm leading-none font-medium"},
    muted: %{tag: "p", classes: "text-muted-foreground text-sm leading-normal"},
    blockquote: %{tag: "blockquote", classes: "border-l-2 pl-6 text-muted-foreground italic"},
    inline_code: %{
      tag: "code",
      classes:
        "bg-muted text-foreground rounded px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold"
    },
    list: %{tag: "ul", classes: "my-6 ml-6 list-disc [&>li]:mt-2"}
  ]
  @typography_variant_values Keyword.keys(@typography_variants)
  @typography_tag_values @typography_variants
                         |> Keyword.values()
                         |> Enum.map(& &1.tag)
                         |> Kernel.++(~w(h5 h6 ol span))
                         |> Enum.uniq()

  doc("""
  Card container.

  ## Examples

  ```heex title="Project status"
  <.card>
    <.card_header>
      <.card_title>Project status</.card_title>
      <.card_description>Active deployments across environments.</.card_description>
    </.card_header>
    <.card_content>
      <p class="text-sm">Production healthy, staging pending one migration.</p>
    </.card_content>
  </.card>
  ```

  ```heex title="Team invite" vrt
  <.card class="max-w-md">
    <.card_header class="border-b">
      <.card_title>Team invite</.card_title>
      <.card_action>
        <.button size={:sm} variant={:outline}>Skip</.button>
      </.card_action>
      <.card_description>Invite teammates before launch.</.card_description>
    </.card_header>
    <.card_content class="space-y-3">
      <.field>
        <:label for="invite_email">Email</:label>
        <.input id="invite_email" type="email" placeholder="dev@company.com" />
      </.field>
    </.card_content>
    <.card_footer class="justify-end gap-2 border-t">
      <.button variant={:outline}>Cancel</.button>
      <.button>Send invite</.button>
    </.card_footer>
  </.card>
  ```

  ## Minimal

      <.card>
        <.card_header>
          <.card_title>Settings</.card_title>
        </.card_header>
        <.card_content>...</.card_content>
      </.card>
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-card text-card-foreground flex flex-col gap-6 rounded-xl border py-6",
        assigns.class
      ])

    ~H"""
    <div data-slot="card" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Card header section.

  ## Example

  ```heex title="Card header with action" align="full"
  <.card class="max-w-md">
    <.card_header class="border-b">
      <.card_title>Billing</.card_title>
      <.card_action>
        <.button size={:sm} variant={:outline}>Manage</.button>
      </.card_action>
      <.card_description>Usage and invoices for this workspace.</.card_description>
    </.card_header>
    <.card_content>
      <p class="text-sm">Current cycle usage: 72%.</p>
    </.card_content>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card_header(assigns) do
    assigns =
      assign(assigns, :classes, [
        "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6",
        assigns.class
      ])

    ~H"""
    <div data-slot="card-header" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Card title text.

  ## Examples

  ```heex title="Basic title" align="full"
  <.card class="max-w-sm">
    <.card_header>
      <.card_title>Payment method</.card_title>
    </.card_header>
    <.card_content>
      <p class="text-sm">Visa ending in 4242.</p>
    </.card_content>
  </.card>
  ```

  ```heex title="Custom title size" align="full"
  <.card class="max-w-sm">
    <.card_header>
      <.card_title class="text-xl">Pro plan</.card_title>
      <.card_description>Renews on the 1st of each month.</.card_description>
    </.card_header>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card_title(assigns) do
    assigns = assign(assigns, :classes, ["leading-none font-semibold", assigns.class])

    ~H"""
    <div data-slot="card-title" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Card description text.

  ## Examples

  ```heex title="Standard description" align="full"
  <.card class="max-w-sm">
    <.card_header>
      <.card_title>Billing setup</.card_title>
      <.card_description>
        Connect your billing details to unlock premium features.
      </.card_description>
    </.card_header>
  </.card>
  ```

  ```heex title="Muted timestamp description" align="full"
  <.card class="max-w-sm">
    <.card_header>
      <.card_title>System status</.card_title>
      <.card_description class="text-xs">Last updated 5 minutes ago.</.card_description>
    </.card_header>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card_description(assigns) do
    assigns = assign(assigns, :classes, ["text-muted-foreground text-sm", assigns.class])

    ~H"""
    <div data-slot="card-description" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Right-aligned card action region for buttons/chips.

  ## Example

  ```heex title="Header action slot" align="full"
  <.card class="max-w-sm">
    <.card_header>
      <.card_title>Project details</.card_title>
      <.card_action>
        <.button size={:sm} variant={:ghost}>Edit</.button>
      </.card_action>
      <.card_description>Manage metadata and ownership.</.card_description>
    </.card_header>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card_action(assigns) do
    assigns =
      assign(assigns, :classes, [
        "col-start-2 row-span-2 row-start-1 self-start justify-self-end",
        assigns.class
      ])

    ~H"""
    <div data-slot="card-action" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Card content section.

  ## Example

  ```heex title="Card content body" align="full"
  <.card class="max-w-md">
    <.card_header>
      <.card_title>API key</.card_title>
      <.card_description>Use this key for network requests.</.card_description>
    </.card_header>
    <.card_content class="space-y-3">
      <p class="text-sm">Your API key was generated successfully.</p>
      <.input_group>
        <.input value="ck_live_************************" readonly />
        <.input_group_addon>
          <.input_group_button variant={:outline}>Copy</.input_group_button>
        </.input_group_addon>
      </.input_group>
    </.card_content>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card_content(assigns) do
    assigns = assign(assigns, :classes, ["px-6", assigns.class])

    ~H"""
    <div data-slot="card-content" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Card footer section.

  ## Example

  ```heex title="Card footer actions" align="full"
  <.card class="max-w-sm">
    <.card_header>
      <.card_title>Notification settings</.card_title>
      <.card_description>Choose how you want to be notified.</.card_description>
    </.card_header>
    <.card_footer class="justify-end gap-2 border-t">
      <.button variant={:outline}>Cancel</.button>
      <.button>Save</.button>
    </.card_footer>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card_footer(assigns) do
    assigns =
      assign(assigns, :classes, ["flex items-center px-6 [.border-t]:pt-6", assigns.class])

    ~H"""
    <div data-slot="card-footer" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  A bordered surface with card-like styling but no inner padding or gap,
  for flexible layouts where the caller controls spacing.

  ## Example

  ```heex title="Panel with custom content"
  <.panel class="max-w-md">
    <div class="p-4 border-b">
      <h3 class="text-sm font-medium">Notifications</h3>
    </div>
    <ul class="divide-y">
      <li class="px-4 py-3 text-sm">New deployment completed</li>
      <li class="px-4 py-3 text-sm">Invite accepted by teammate</li>
    </ul>
  </.panel>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def panel(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-card text-card-foreground flex flex-col rounded-xl border",
        assigns.class
      ])

    ~H"""
    <div data-slot="panel" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Horizontal or vertical separator.

  ## Example

  ```heex title="Horizontal separator" align="full"
  <div class="space-y-3">
    <p class="text-sm">Overview</p>
    <.separator />
    <p class="text-sm">Details</p>
  </div>
  ```
  """)

  attr :orientation, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :decorative, :boolean, default: true
  attr :class, :string, default: nil
  attr :rest, :global

  def separator(assigns) do
    orientation_classes =
      case assigns.orientation do
        :horizontal -> "data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full"
        :vertical -> "data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px"
      end

    assigns =
      assign(assigns, :classes, [
        "bg-border shrink-0",
        orientation_classes,
        assigns.class
      ])

    ~H"""
    <div
      data-slot="separator"
      role={if(@decorative, do: "none", else: "separator")}
      aria-orientation={@orientation}
      data-orientation={@orientation}
      class={classes(@classes)}
      {@rest}
    />
    """
  end

  doc("""
  Animated skeleton placeholder.

  ## Examples

  ```heex title="Single line placeholder"
  <.skeleton class="h-4 w-[220px]" />
  ```

  ```heex title="Avatar + text row" align="full"
  <div class="flex items-center gap-3">
    <.skeleton class="size-10 rounded-full" />
    <div class="space-y-2">
      <.skeleton class="h-4 w-[180px]" />
      <.skeleton class="h-4 w-[120px]" />
    </div>
  </div>
  ```

  ```heex title="Card loading state" align="full" vrt
  <.card class="max-w-sm">
    <.card_header>
      <.skeleton class="h-5 w-[140px]" />
      <.skeleton class="h-4 w-[220px]" />
    </.card_header>
    <.card_content class="space-y-2">
      <.skeleton class="h-4 w-full" />
      <.skeleton class="h-4 w-[90%]" />
      <.skeleton class="h-4 w-[75%]" />
    </.card_content>
  </.card>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global

  def skeleton(assigns) do
    assigns = assign(assigns, :classes, ["bg-accent animate-pulse rounded-md", assigns.class])

    ~H"""
    <div data-slot="skeleton" class={classes(@classes)} {@rest} />
    """
  end

  doc("""
  Maintains a fixed aspect ratio for content.

  ## Example

      <.aspect_ratio ratio="16 / 9">
        <img src="https://picsum.photos/id/191/800/800" class="h-full w-full object-cover" />
      </.aspect_ratio>
  """)

  attr :ratio, :string, default: "16 / 9"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def aspect_ratio(assigns) do
    assigns = assign(assigns, :classes, ["relative w-full overflow-hidden", assigns.class])

    ~H"""
    <div data-slot="aspect-ratio" class={classes(@classes)} style={"aspect-ratio: #{@ratio};"} {@rest}>
      <div class="absolute inset-0">{render_slot(@inner_block)}</div>
    </div>
    """
  end

  doc("""
  Keyboard key badge.

  ## Examples

  ```heex title="Single shortcut key"
  <.kbd>⌘K</.kbd>
  ```

  ```heex title="Shortcut combination"
  <.kbd_group>
    <.kbd>⌘</.kbd>
    <.kbd>K</.kbd>
  </.kbd_group>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def kbd(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-muted text-muted-foreground pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center gap-1 rounded-sm px-1 font-sans text-xs font-medium select-none [&_svg:not([class*='size-'])]:size-3",
        assigns.class
      ])

    ~H"""
    <kbd data-slot="kbd" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</kbd>
    """
  end

  doc("""
  Groups multiple `kbd/1` entries.

  ## Example

  ```heex title="Key group"
  <.kbd_group>
    <.kbd>⌘</.kbd>
    <.kbd>⇧</.kbd>
    <.kbd>P</.kbd>
  </.kbd_group>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def kbd_group(assigns) do
    assigns = assign(assigns, :classes, ["inline-flex items-center gap-1", assigns.class])

    ~H"""
    <kbd data-slot="kbd-group" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</kbd>
    """
  end

  doc("""
  Shadcn-inspired typography recipe for semantic headings and text treatments.

  `typography/1` is intentionally small: it applies token-based Tailwind
  classes to a single semantic element and does not style arbitrary prose
  descendants. Use `as` when the visual treatment should render as a different
  HTML tag.

  ## Attributes

  - `variant`: `:h1 | :h2 | :h3 | :h4 | :p | :lead | :large | :small | :muted | :blockquote | :inline_code | :list`
  - `as`: optional HTML tag override for typography-safe text tags

  ## Examples

  ```heex title="Article heading stack" align="full" vrt
  <div class="max-w-2xl">
    <.typography variant={:h1}>Realtime payments need boring interfaces</.typography>
    <.typography variant={:lead} class="mt-4">
      Operators need clear hierarchy, calm defaults, and text that survives dense workflows.
    </.typography>
    <.typography>
      Use typography recipes when component copy needs consistent rhythm without introducing
      a rich text renderer or client-side dependency.
    </.typography>
  </div>
  ```

  ```heex title="Inline UI copy" align="full"
  <div class="max-w-md space-y-3">
    <.typography variant={:h3}>Workspace limits</.typography>
    <.typography variant={:muted}>
      API keys expire after <.typography variant={:inline_code}>90d</.typography>.
    </.typography>
    <.typography variant={:small} as="p">Last updated by the billing service.</.typography>
  </div>
  ```

  ```heex title="List recipe" align="full"
  <.typography variant={:list}>
    <li>Keep headings semantic.</li>
    <li>Use tokens like <.typography variant={:inline_code}>text-muted-foreground</.typography>.</li>
    <li>Reach for component slots before custom wrappers.</li>
  </.typography>
  ```
  """)

  attr :variant, :atom,
    default: :p,
    values: @typography_variant_values

  attr :as, :string, default: nil, values: [nil | @typography_tag_values]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def typography(assigns) do
    variant = Keyword.fetch!(@typography_variants, assigns.variant)

    assigns =
      assigns
      |> assign(:tag_name, assigns.as || variant.tag)
      |> assign(:classes, [
        variant.classes,
        assigns.class
      ])

    ~H"""
    <.dynamic_tag
      tag_name={@tag_name}
      data-slot="typography"
      data-variant={@variant}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  doc("""
  Overflow container that mirrors shadcn `scroll-area` structure.

  ## Example

  ```heex title="Scrollable container" align="full"
  <.scroll_area class="h-24 rounded-md border">
    <div class="space-y-2 text-sm p-4">
      <div>Scrollable content</div>
      <div>Scrollable content</div>
      <div>Scrollable content</div>
      <div>Scrollable content</div>
      <div>Scrollable content</div>
    </div>
  </.scroll_area>
  ```
  """)

  attr :class, :string, default: nil
  attr :viewport_class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def scroll_area(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative overflow-hidden", assigns.class])
      |> assign(:viewport_classes, [
        "h-full w-full rounded-[inherit] overflow-auto",
        assigns.viewport_class
      ])

    ~H"""
    <div data-slot="scroll-area" class={classes(@classes)} {@rest}>
      <div data-slot="scroll-area-viewport" class={classes(@viewport_classes)}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  doc("""
  Resizable split layout container with optional client-side persistence.

  > #### Current Scope
  >
  > `resizable/1` currently supports adjacent panel resizing, keyboard handle
  > controls, optional visible handles, and `localStorage` persistence.
  > It does not yet include collapsed panels, imperative panel APIs, or the
  > richer nested-group ergonomics of a full panel system.

  Uses the optional `CuiResizable` LiveView hook to support drag handles.
  Provide `storage_key` to persist panel percentages in `localStorage`.

  ## Example

  ```heex title="Default" align="full"
  <.resizable id="resizable-1">
    <:panel size={35}>
      <div class="rounded-md bg-muted p-2 text-xs">Panel A</div>
    </:panel>
    <:panel size={65}>
      <div class="rounded-md bg-muted/60 p-2 text-xs">Panel B</div>
    </:panel>
  </.resizable>
  ```

  ```heex title="Vertical" align="full" vrt
  <.resizable id="resizable-2" direction={:vertical} class="h-[240px]">
    <:panel size={45}>
      <div class="h-full rounded-md bg-muted p-2 text-xs">Top panel</div>
    </:panel>
    <:panel size={55}>
      <div class="h-full rounded-md bg-muted/60 p-2 text-xs">Bottom panel</div>
    </:panel>
  </.resizable>
  ```

  ```heex title="Handle + persisted sizes" align="full" vrt
  <.resizable id="resizable-3" with_handle storage_key="docs-layout-main">
    <:panel size={30} min_size={20}>
      <div class="rounded-md bg-muted p-2 text-xs">Explorer</div>
    </:panel>
    <:panel size={70} min_size={30}>
      <div class="rounded-md bg-muted/60 p-2 text-xs">Editor</div>
    </:panel>
  </.resizable>
  ```
  """)

  attr :direction, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :with_handle, :boolean, default: false
  attr :storage_key, :string, default: nil
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :panel, required: true do
    attr :size, :integer
    attr :min_size, :integer
    attr :class, :string
  end

  def resizable(assigns) do
    assigns =
      assigns
      |> assign(:classes, [
        "flex min-h-[200px] w-full data-[direction=vertical]:flex-col data-[direction=horizontal]:flex-row",
        assigns.class
      ])
      |> assign_new(:id, fn -> "cinder-ui-resizable-#{System.unique_integer([:positive])}" end)
      |> assign(:panel_count, length(assigns.panel))

    ~H"""
    <div
      id={@id}
      data-slot="resizable"
      data-direction={@direction}
      data-storage-key={@storage_key}
      class={classes(@classes)}
      phx-hook="CuiResizable"
      {@rest}
    >
      <.resizable_panel_pair
        :for={{panel, index} <- Enum.with_index(@panel)}
        panel={panel}
        index={index}
        panel_count={@panel_count}
        direction={@direction}
        with_handle={@with_handle}
      />
    </div>
    """
  end

  attr :panel, :map, required: true
  attr :index, :integer, required: true
  attr :panel_count, :integer, required: true
  attr :direction, :atom, required: true
  attr :with_handle, :boolean, required: true

  defp resizable_panel_pair(assigns) do
    ~H"""
    <div
      data-slot="resizable-panel"
      data-size={@panel[:size]}
      data-min-size={@panel[:min_size]}
      style={if(@panel[:size], do: "flex: 0 0 #{@panel[:size]}%;", else: nil)}
      class={classes(["relative min-h-0 min-w-0 shrink-0", @panel[:class]])}
    >
      {render_slot(@panel)}
    </div>
    <div
      :if={@index < @panel_count - 1}
      data-slot="resizable-handle"
      data-with-handle={@with_handle}
      role="separator"
      tabindex="0"
      aria-orientation={@direction}
      class={
        classes([
          "bg-border relative shrink-0 touch-none outline-none focus-visible:ring-ring/50 focus-visible:ring-[3px]",
          if(@direction == :horizontal, do: "w-px cursor-col-resize", else: "h-px cursor-row-resize")
        ])
      }
    >
      <span
        aria-hidden="true"
        class={
          classes([
            "absolute bg-transparent",
            if(@direction == :horizontal, do: "inset-y-0 -left-2 w-5", else: "inset-x-0 -top-2 h-5")
          ])
        }
      />
      <span
        :if={@with_handle}
        aria-hidden="true"
        class={
          classes([
            "bg-border rounded-sm border border-border/60 p-1 shadow-xs",
            "bg-background absolute top-1/2 left-1/2 inline-flex -translate-x-1/2 -translate-y-1/2 items-center justify-center"
          ])
        }
      >
        <span class={
          classes([
            "bg-muted-foreground/80 block rounded-full",
            if(@direction == :horizontal, do: "h-6 w-px", else: "h-px w-6")
          ])
        } />
      </span>
    </div>
    """
  end
end
