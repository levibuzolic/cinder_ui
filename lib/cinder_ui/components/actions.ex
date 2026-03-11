defmodule CinderUI.Components.Actions do
  @moduledoc """
  Action-oriented shadcn-style components.

  This module includes:

  - `button/1`
  - `button_group/1`
  - `toggle/1`
  - `toggle_group/1`

  ## Usage

      <.button>Save</.button>
      <.button variant={:outline} size={:sm}>Cancel</.button>
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  @button_variants %{
    default: "bg-primary text-primary-foreground hover:bg-primary/90",
    destructive:
      "bg-destructive text-white hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline:
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50",
    secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
    link: "text-primary underline-offset-4 hover:underline"
  }

  @button_sizes %{
    default: "h-9 px-4 py-2 has-[>svg]:px-3",
    xs:
      "h-6 gap-1 rounded-md px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3",
    sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
    lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
    icon: "size-9",
    icon_xs: "size-6 rounded-md [&_svg:not([class*='size-'])]:size-3",
    icon_sm: "size-8",
    icon_lg: "size-10"
  }

  doc("""
  Renders a shadcn-style button.

  ## Attributes

  - `variant`: `:default | :destructive | :outline | :secondary | :ghost | :link`
  - `size`: `:default | :xs | :sm | :lg | :icon | :icon_xs | :icon_sm | :icon_lg`
  - `as`: html tag (`"button"` by default, often `"a"`)
  - `loading`: toggles an inline spinner

  ## Examples

  ```heex title="Primary submit action"
  <.button type="submit">Save changes</.button>
  ```

  ```heex title="Outline small action"
  <.button variant={:outline} size={:sm}>Edit</.button>
  ```

  ```heex title="Ghost icon action"
  <.button variant={:ghost} size={:icon} aria-label="Refresh">
    <CinderUI.Icons.icon name="refresh-cw" />
  </.button>
  ```

  ```heex title="Link-style navigation button"
  <.button as="a" href="/billing" variant={:link}>Manage billing</.button>
  ```

  ```heex title="Loading destructive action"
  <.button variant={:destructive} loading={true}>Deleting...</.button>
  ```
  """)

  attr :as, :string, default: "button"

  attr :variant, :atom,
    default: :default,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link]

  attr :size, :atom,
    default: :default,
    values: [:default, :xs, :sm, :lg, :icon, :icon_xs, :icon_sm, :icon_lg]

  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(type href target rel disabled name value form id aria-label)
  slot :inner_block, required: true

  def button(assigns) do
    assigns =
      assign(assigns, :classes, [
        "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        variant(@button_variants, assigns.variant, @button_variants.default),
        variant(@button_sizes, assigns.size, @button_sizes.default),
        assigns.class
      ])

    ~H"""
    <.dynamic_tag
      data-slot="button"
      data-variant={@variant}
      data-size={@size}
      tag_name={@as}
      class={classes(@classes)}
      {@rest}
    >
      <CinderUI.Icons.icon
        :if={@loading}
        name="loader-circle"
        class="size-4 animate-spin"
        aria-hidden="true"
      />
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  doc("""
  Renders a horizontal or vertical button group.

  ## Examples

  ```heex title="Primary and secondary actions"
  <.button_group>
    <.button>Deploy</.button>
    <.button variant={:outline}>Rollback</.button>
  </.button_group>
  ```

  ```heex title="Compact table row controls"
  <.button_group>
    <.button size={:sm} variant={:secondary}>Edit</.button>
    <.button size={:sm} variant={:outline}>Duplicate</.button>
    <.button size={:sm} variant={:destructive}>Archive</.button>
  </.button_group>
  ```

  ```heex title="Vertical stack for mobile sheets"
  <.button_group orientation={:vertical} class="w-full">
    <.button class="w-full">Save draft</.button>
    <.button class="w-full" variant={:outline}>Discard</.button>
  </.button_group>
  ```

  ```heex title="Wizard navigation"
      <.button_group>
        <.button size={:sm}>Back</.button>
        <.button size={:sm}>Next</.button>
      </.button_group>
  ```
  """)

  attr :orientation, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def button_group(assigns) do
    orientation_classes =
      case assigns.orientation do
        :horizontal ->
          "inline-flex items-center [&>*]:relative [&>*]:z-0 [&>*:hover]:z-10 [&>*:focus-visible]:z-10 [&>*:not(:first-child)]:-ml-px [&>*:first-child]:rounded-r-none [&>*:not(:first-child):not(:last-child)]:rounded-none [&>*:last-child]:rounded-l-none"

        :vertical ->
          "inline-flex flex-col [&>*]:relative [&>*]:z-0 [&>*:hover]:z-10 [&>*:focus-visible]:z-10 [&>*:not(:first-child)]:-mt-px [&>*:first-child]:rounded-b-none [&>*:not(:first-child):not(:last-child)]:rounded-none [&>*:last-child]:rounded-t-none"
      end

    assigns = assign(assigns, :classes, [orientation_classes, assigns.class])

    ~H"""
    <div data-slot="button-group" data-orientation={@orientation} class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @toggle_variants %{
    default: "bg-transparent",
    outline:
      "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
  }

  @toggle_sizes %{
    default: "h-9 px-2 min-w-9",
    sm: "h-8 px-1.5 min-w-8",
    lg: "h-10 px-2.5 min-w-10"
  }

  doc("""
  Renders a shadcn-style toggle button.

  ## Examples

  ```heex title="Default toggle"
  <.toggle pressed={true}>Bold</.toggle>
  ```

  ```heex title="Outline variant"
  <.toggle variant={:outline}>
    <CinderUI.Icons.icon name="italic" />
    Italic
  </.toggle>
  ```

  ```heex title="Sizes"
  <div class="flex items-center gap-2">
    <.toggle size={:sm}>S</.toggle>
    <.toggle>Default</.toggle>
    <.toggle size={:lg}>Large</.toggle>
  </div>
  ```

  ```heex title="Disabled toggle"
  <.toggle disabled>Disabled</.toggle>
  ```
  """)

  attr :pressed, :boolean, default: false
  attr :variant, :atom, default: :default, values: [:default, :outline]
  attr :size, :atom, default: :default, values: [:default, :sm, :lg]
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(type id name value disabled aria-label)
  slot :inner_block, required: true

  def toggle(assigns) do
    state = if(assigns.pressed, do: "on", else: "off")

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:classes, [
        "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium hover:bg-muted hover:text-muted-foreground disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0 focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] outline-none transition-[color,box-shadow] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive whitespace-nowrap",
        variant(@toggle_variants, assigns.variant, @toggle_variants.default),
        variant(@toggle_sizes, assigns.size, @toggle_sizes.default),
        assigns.class
      ])

    ~H"""
    <button
      type="button"
      data-slot="toggle"
      data-state={@state}
      aria-pressed={@pressed}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  doc("""
  Groups toggles in either single-select or multi-select mode.

  This component provides structure and classes only. State management should be
  handled by LiveView assigns or JS hooks.

  ## Examples

  ```heex title="Single-select alignment controls"
  <.toggle_group type={:single}>
    <.toggle>Left</.toggle>
    <.toggle pressed={true}>Center</.toggle>
    <.toggle>Right</.toggle>
  </.toggle_group>
  ```

  ```heex title="Multi-select text formatting"
  <.toggle_group type={:multiple}>
    <.toggle pressed={true}>Bold</.toggle>
    <.toggle>Italic</.toggle>
    <.toggle pressed={true}>Underline</.toggle>
  </.toggle_group>
  ```

  ```heex title="Vertical stack"
  <.toggle_group orientation={:vertical} class="items-start">
    <.toggle>Alpha</.toggle>
    <.toggle pressed={true}>Beta</.toggle>
    <.toggle>Gamma</.toggle>
  </.toggle_group>
  ```
  """)

  attr :type, :atom, default: :single, values: [:single, :multiple]
  attr :orientation, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def toggle_group(assigns) do
    orientation_classes =
      case assigns.orientation do
        :horizontal -> "inline-flex items-center gap-1"
        :vertical -> "inline-flex flex-col gap-1"
      end

    assigns = assign(assigns, :classes, [orientation_classes, assigns.class])

    ~H"""
    <div
      data-slot="toggle-group"
      data-type={@type}
      data-orientation={@orientation}
      role="group"
      class={classes(@classes)}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
