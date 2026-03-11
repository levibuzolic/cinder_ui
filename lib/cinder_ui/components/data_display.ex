defmodule CinderUI.Components.DataDisplay do
  @moduledoc """
  Data-display components following shadcn/ui structure where feasible.

  Included:

  - Avatar family (`avatar/1`, `avatar_group/1`, `avatar_group_count/1`)
  - Table family (`table/1`, `table_header/1`, `table_body/1`, `table_footer/1`, `table_row/1`, `table_head/1`, `table_cell/1`, `table_caption/1`)
  - `accordion/1`
  - `collapsible/1`
  - `code_block/1`
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  doc("""
  Renders a circular avatar with optional image and fallback.

  ## Examples

  ```heex title="Image with fallback"
  <.avatar src="example.png" alt="Levi" fallback="LV" />
  ```

  ```heex title="Fallback initials only"
  <.avatar alt="Mira Chen" />
  ```

  ```heex title="Sizes"
  <div class="flex items-center gap-3">
    <.avatar size={:sm} alt="Small User" />
    <.avatar alt="Default User" />
    <.avatar size={:lg} alt="Large User" />
  </div>
  ```

  ```heex title="Presence badge"
  <.avatar src="example.png" alt="Online User">
    <:badge><span class="sr-only">Online</span></:badge>
  </.avatar>
  ```
  """)

  attr :src, :string, default: nil
  attr :alt, :string, default: ""
  attr :fallback, :string, default: nil
  attr :size, :atom, default: :default, values: [:sm, :default, :lg]
  attr :class, :string, default: nil
  slot :badge

  def avatar(assigns) do
    size_class =
      case assigns.size do
        :sm -> "size-6"
        :default -> "size-8"
        :lg -> "size-10"
      end

    fallback =
      case assigns.fallback do
        nil ->
          assigns.alt
          |> to_string()
          |> String.split(~r/\s+/, trim: true)
          |> Enum.map(&String.first/1)
          |> Enum.take(2)
          |> Enum.join()
          |> String.upcase()

        value ->
          value
      end

    assigns =
      assigns
      |> assign(:fallback_text, fallback)
      |> assign(:classes, [
        "group/avatar relative flex shrink-0 overflow-hidden rounded-full select-none",
        size_class,
        assigns.class
      ])

    ~H"""
    <div data-slot="avatar" data-size={@size} class={classes(@classes)}>
      <img
        :if={@src}
        data-slot="avatar-image"
        src={@src}
        alt={@alt}
        class="aspect-square size-full"
        loading="lazy"
      />
      <div
        :if={!@src}
        data-slot="avatar-fallback"
        class="bg-muted text-muted-foreground flex size-full items-center justify-center rounded-full text-sm"
      >
        {@fallback_text}
      </div>
      <span
        :if={@badge != []}
        data-slot="avatar-badge"
        class="bg-primary text-primary-foreground ring-background absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full ring-2 size-2.5"
      >
        {render_slot(@badge)}
      </span>
    </div>
    """
  end

  doc("""
  Groups avatars with overlap.

  ## Examples

  ```heex title="Team avatars"
  <.avatar_group>
    <.avatar src="example.png" alt="Levi" />
    <.avatar src="example.png" alt="Mira" />
    <.avatar src="example.png" alt="Shadcn" />
    <.avatar_group_count>+2</.avatar_group_count>
  </.avatar_group>
  ```

  ```heex title="Fallback-only group"
  <.avatar_group>
    <.avatar alt="Levi Buzolic" />
    <.avatar alt="Mira Jones" />
    <.avatar alt="Sam Patel" />
  </.avatar_group>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def avatar_group(assigns) do
    assigns =
      assign(assigns, :classes, [
        "*:data-[slot=avatar]:ring-background group/avatar-group flex -space-x-2 *:data-[slot=avatar]:ring-2",
        assigns.class
      ])

    ~H"""
    <div data-slot="avatar-group" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Counter item for avatar groups (e.g. `+3`).

  ## Example

  ```heex title="Avatar overflow count"
  <.avatar_group>
    <.avatar alt="Levi Buzolic" />
    <.avatar alt="Mira Jones" />
    <.avatar_group_count>+3</.avatar_group_count>
  </.avatar_group>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def avatar_group_count(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-muted text-muted-foreground ring-background relative flex size-8 shrink-0 items-center justify-center rounded-full text-sm ring-2",
        assigns.class
      ])

    ~H"""
    <div data-slot="avatar-group-count" class={classes(@classes)}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Table wrapper with overflow container.

  ## Examples

  ```heex title="Service status table" align="full"
  <.table>
    <.table_caption>Active deployments across environments.</.table_caption>
    <.table_header>
      <.table_row>
        <.table_head>Service</.table_head>
        <.table_head>Status</.table_head>
        <.table_head class="text-right">Latency</.table_head>
      </.table_row>
    </.table_header>
    <.table_body>
      <.table_row>
        <.table_cell>API</.table_cell>
        <.table_cell>Healthy</.table_cell>
        <.table_cell class="text-right">82ms</.table_cell>
      </.table_row>
      <.table_row>
        <.table_cell>Worker</.table_cell>
        <.table_cell>Degraded</.table_cell>
        <.table_cell class="text-right">164ms</.table_cell>
      </.table_row>
    </.table_body>
  </.table>
  ```

  ```heex title="Invoice summary table" align="full" vrt
  <.table>
    <.table_header>
      <.table_row>
        <.table_head>Invoice</.table_head>
        <.table_head>State</.table_head>
        <.table_head class="text-right">Amount</.table_head>
      </.table_row>
    </.table_header>
    <.table_body>
      <.table_row>
        <.table_cell>INV-001</.table_cell>
        <.table_cell>Paid</.table_cell>
        <.table_cell class="text-right">$120.00</.table_cell>
      </.table_row>
      <.table_row state="selected">
        <.table_cell>INV-002</.table_cell>
        <.table_cell>Pending</.table_cell>
        <.table_cell class="text-right">$48.00</.table_cell>
      </.table_row>
    </.table_body>
    <.table_footer>
      <.table_row>
        <.table_cell class="font-medium" colspan="2">Total</.table_cell>
        <.table_cell class="text-right font-medium">$168.00</.table_cell>
      </.table_row>
    </.table_footer>
  </.table>
  ```

  ## Minimal

  ```heex title="Minimal table"
  <.table>
    <.table_header>
      <.table_row>
        <.table_head>Name</.table_head>
      </.table_row>
    </.table_header>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def table(assigns) do
    assigns = assign(assigns, :classes, ["w-full caption-bottom text-sm", assigns.class])

    ~H"""
    <div data-slot="table-container" class="relative w-full overflow-x-auto">
      <table data-slot="table" class={classes(@classes)}>
        {render_slot(@inner_block)}
      </table>
    </div>
    """
  end

  doc("""
  Table header (`thead`).

  ## Example

  ```heex title="Table header" align="full"
  <.table>
    <.table_header>
      <.table_row>
        <.table_head>Name</.table_head>
        <.table_head>Status</.table_head>
      </.table_row>
    </.table_header>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def table_header(assigns) do
    assigns = assign(assigns, :classes, ["[&_tr]:border-b", assigns.class])

    ~H"""
    <thead data-slot="table-header" class={classes(@classes)}>{render_slot(@inner_block)}</thead>
    """
  end

  doc("""
  Table body (`tbody`).

  ## Example

  ```heex title="Table body" align="full"
  <.table>
    <.table_body>
      <.table_row>
        <.table_cell>API</.table_cell>
        <.table_cell>Healthy</.table_cell>
      </.table_row>
    </.table_body>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def table_body(assigns) do
    assigns = assign(assigns, :classes, ["[&_tr:last-child]:border-0", assigns.class])

    ~H"""
    <tbody data-slot="table-body" class={classes(@classes)}>{render_slot(@inner_block)}</tbody>
    """
  end

  doc("""
  Table footer (`tfoot`).

  ## Example

  ```heex title="Table footer" align="full"
  <.table>
    <.table_footer>
      <.table_row>
        <.table_cell colspan="2" class="font-medium">Total</.table_cell>
      </.table_row>
    </.table_footer>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def table_footer(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-muted/50 border-t font-medium [&>tr]:last:border-b-0",
        assigns.class
      ])

    ~H"""
    <tfoot data-slot="table-footer" class={classes(@classes)}>{render_slot(@inner_block)}</tfoot>
    """
  end

  doc("""
  Table row (`tr`).

  ## Example

  ```heex title="Selected row" align="full"
  <.table>
    <.table_body>
      <.table_row state="selected">
        <.table_cell>INV-002</.table_cell>
        <.table_cell>Pending</.table_cell>
      </.table_row>
    </.table_body>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  attr :state, :string, default: nil
  slot :inner_block, required: true

  def table_row(assigns) do
    assigns =
      assign(assigns, :classes, [
        "hover:bg-muted/50 data-[state=selected]:bg-muted border-b transition-colors",
        assigns.class
      ])

    ~H"""
    <tr data-slot="table-row" data-state={@state} class={classes(@classes)}>
      {render_slot(@inner_block)}
    </tr>
    """
  end

  doc("""
  Table heading cell (`th`).

  ## Example

  ```heex title="Header cell" align="full"
  <.table>
    <.table_header>
      <.table_row>
        <.table_head class="text-right">Amount</.table_head>
      </.table_row>
    </.table_header>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def table_head(assigns) do
    assigns =
      assign(assigns, :classes, [
        "text-foreground h-10 px-2 text-left align-middle font-medium whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
        assigns.class
      ])

    ~H"""
    <th data-slot="table-head" class={classes(@classes)}>{render_slot(@inner_block)}</th>
    """
  end

  doc("""
  Table data cell (`td`).

  ## Example

  ```heex title="Data cell" align="full"
  <.table>
    <.table_body>
      <.table_row>
        <.table_cell>$48.00</.table_cell>
      </.table_row>
    </.table_body>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(colspan rowspan)
  slot :inner_block, required: true

  def table_cell(assigns) do
    assigns =
      assign(assigns, :classes, [
        "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
        assigns.class
      ])

    ~H"""
    <td data-slot="table-cell" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</td>
    """
  end

  doc("""
  Table caption (`caption`).

  ## Example

  ```heex title="Table caption" align="full"
  <.table>
    <.table_caption>Recent invoices</.table_caption>
  </.table>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def table_caption(assigns) do
    assigns = assign(assigns, :classes, ["text-muted-foreground mt-4 text-sm", assigns.class])

    ~H"""
    <caption data-slot="table-caption" class={classes(@classes)}>{render_slot(@inner_block)}</caption>
    """
  end

  doc("""
  Accordion with multiple items.

  Uses `<details>` for no-JS progressive enhancement.

  ## Examples

  ```heex title="FAQ accordion" align="full"
  <.accordion>
    <:item title="What is CinderUI?" open={true}>
      A Phoenix-first component library modeled after shadcn/ui patterns.
    </:item>
    <:item title="Does it require JavaScript?">
      Core interactions use semantic HTML first, with optional hooks for enhancement.
    </:item>
  </.accordion>
  ```

  ```heex title="Release notes" align="full"
  <.accordion>
    <:item title="v0.4.0 · New components" open={true}>
      Added pagination, tabs, and command palette docs pages.
    </:item>
    <:item title="v0.3.2 · Docs quality">
      Added generated attr and slot tables plus HEEx copy snippets.
    </:item>
    <:item title="v0.3.0 · Static site">
      Introduced static docs export and theme controls.
    </:item>
  </.accordion>
  ```
  """)

  attr :class, :string, default: nil

  slot :item, required: true do
    attr :title, :string, required: true
    attr :open, :boolean
  end

  def accordion(assigns) do
    assigns = assign(assigns, :classes, ["w-full", assigns.class])

    ~H"""
    <div data-slot="accordion" class={classes(@classes)}>
      <details
        :for={item <- @item}
        data-slot="accordion-item"
        open={Map.get(item, :open, false)}
        class="border-b last:border-b-0"
      >
        <summary
          data-slot="accordion-trigger"
          class="focus-visible:border-ring focus-visible:ring-ring/50 flex flex-1 items-start justify-between gap-4 rounded-md py-4 text-left text-sm font-medium transition-all outline-none hover:underline focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 cursor-pointer"
        >
          {item.title}
          <span class="text-muted-foreground pointer-events-none size-4 shrink-0 translate-y-0.5">
            ⌄
          </span>
        </summary>
        <div data-slot="accordion-content" class="overflow-hidden text-sm">
          <div class="pt-0 pb-4">{render_slot(item)}</div>
        </div>
      </details>
    </div>
    """
  end

  doc("""
  Generic collapsible section with trigger/content slots.

  Uses `<details>` for accessibility and no-JS behavior.

  ## Example

  ```heex title="Collapsible details" align="full"
  <.collapsible open={true}>
    <:trigger>
      Release notes
    </:trigger>
    Added generated attr tables and improved examples.
  </.collapsible>
  ```
  """)

  attr :open, :boolean, default: false
  attr :class, :string, default: nil
  slot :trigger, required: true
  slot :inner_block, required: true

  def collapsible(assigns) do
    assigns = assign(assigns, :classes, ["w-full rounded-md border px-4", assigns.class])

    ~H"""
    <details data-slot="collapsible" open={@open} class={classes(@classes)}>
      <summary
        data-slot="collapsible-trigger"
        class="flex cursor-pointer list-none items-center justify-between py-3 text-sm font-medium"
      >
        {render_slot(@trigger)}
        <span class="text-muted-foreground">⌄</span>
      </summary>
      <div data-slot="collapsible-content" class="pb-4 text-sm text-muted-foreground">
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  doc("""
  Monospaced code block wrapper.

  ## Example

  ```heex title="Code block" align="full"
  <.code_block>
    mix cinder_ui.docs.build
  </.code_block>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def code_block(assigns) do
    assigns =
      assign(assigns, :classes, [
        "relative rounded-lg border bg-muted/30 px-4 py-3 font-mono text-sm text-foreground",
        assigns.class
      ])

    ~H"""
    <pre data-slot="code-block" class={classes(@classes)}><code><%= render_slot(@inner_block) %></code></pre>
    """
  end
end
