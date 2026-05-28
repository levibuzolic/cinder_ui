defmodule CinderUI.Components.FieldFamily do
  @moduledoc """
  Structural field-family components for grouping and annotating form controls.

  Included components:

  - `field_group/1`
  - `field_set/1`
  - `field_legend/1`
  - `field_content/1`
  - `field_title/1`
  - `field_separator/1`

  [View live Forms examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#forms).
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  doc("""
  Stacks related fields with consistent spacing.

  Use `field_group/1` inside `field_set/1` for semantic form sections, or on
  its own when a form needs a low-level layout wrapper without extra behavior.

  ## Examples

  ```heex title="Field family" align="full" vrt
  <.field_set>
    <.field_legend>Notification preferences</.field_legend>
    <.field_description>Choose how Cinder UI should notify your team.</.field_description>

    <.field_group>
      <.field>
        <:label for="deployments">Deployments</:label>
        <.input id="deployments" name="notifications[deployments]" value="email" />
        <:description>Release and rollback notifications.</:description>
      </.field>

      <.field_separator />

      <.field_control class="flex items-start gap-3">
        <.checkbox id="weekly-summary" name="notifications[weekly_summary]" />
        <.field_content>
          <.field_label>
            <.label for="weekly-summary">Weekly summary</.label>
          </.field_label>
          <.field_description>Send a digest every Monday morning.</.field_description>
        </.field_content>
      </.field_control>
    </.field_group>
  </.field_set>
  ```

  ```heex title="Field group with separator" align="full"
  <.field_group>
    <.field>
      <:label for="response_email">Response emails</:label>
      <.input id="response_email" name="notifications[responses]" />
    </.field>

    <.field_separator>Tasks</.field_separator>

    <.field>
      <:label for="task_email">Task emails</:label>
      <.input id="task_email" name="notifications[tasks]" />
    </.field>
  </.field_group>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_group(assigns) do
    assigns =
      assign(assigns, :classes, [
        "@container/field-group flex flex-col gap-6",
        assigns.class
      ])

    ~H"""
    <div data-slot="field-group" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Semantic fieldset wrapper for grouping related controls.

  Pair `field_set/1` with `field_legend/1`, optional `field_description/1`,
  and `field_group/1` so grouped controls stay accessible and visually
  consistent.

  ## Example

  ```heex title="Field set" align="full"
  <.field_set>
    <.field_legend>Billing address</.field_legend>
    <.field_description>Used for invoices and payment receipts.</.field_description>
    <.field_group>
      <.field>
        <:label for="billing_city">City</:label>
        <.input id="billing_city" name="billing[city]" />
      </.field>
    </.field_group>
  </.field_set>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_set(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex flex-col gap-6",
        assigns.class
      ])

    ~H"""
    <fieldset data-slot="field-set" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end

  doc("""
  Legend for a `field_set/1`.

  The default `:legend` variant is sized for section titles. Use
  `variant={:label}` when nesting fieldsets and you want the legend to align
  with ordinary field labels.

  ## Examples

  ```heex title="Field legend" align="full"
  <.field_legend>Delivery method</.field_legend>
  ```

  ```heex title="Label-sized legend" align="full"
  <.field_legend variant={:label}>Notification channel</.field_legend>
  ```
  """)

  attr :variant, :atom, default: :legend, values: [:legend, :label]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_legend(assigns) do
    variant_classes =
      case assigns.variant do
        :legend -> "text-base font-medium"
        :label -> "text-sm leading-none font-medium"
      end

    assigns =
      assign(assigns, :classes, [
        variant_classes,
        "data-[variant=label]:select-none",
        assigns.class
      ])

    ~H"""
    <legend data-slot="field-legend" data-variant={@variant} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </legend>
    """
  end

  doc("""
  Groups field copy beside an inline control.

  `field_content/1` is useful when a checkbox, switch, or radio item sits next
  to label and helper text.

  ## Example

  ```heex title="Field content" align="full"
  <.field_control class="flex items-start gap-3">
    <.checkbox id="desktop-alerts" name="alerts[desktop]" />
    <.field_content>
      <.field_label>
        <.label for="desktop-alerts">Desktop alerts</.label>
      </.field_label>
      <.field_description>Show deployment alerts on this device.</.field_description>
    </.field_content>
  </.field_control>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_content(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex flex-1 flex-col gap-1.5 leading-none",
        assigns.class
      ])

    ~H"""
    <div data-slot="field-content" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Label-styled title text for custom field content.

  Use `field_title/1` when there is no direct input label target, such as
  selectable cards or composed option rows.

  ## Example

  ```heex title="Field title" align="full"
  <.field_content>
    <.field_title>Virtual machine</.field_title>
    <.field_description>Run workloads on a dedicated host.</.field_description>
  </.field_content>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_title(assigns) do
    assigns =
      assign(assigns, :classes, [
        "text-sm leading-none font-medium",
        assigns.class
      ])

    ~H"""
    <div data-slot="field-title" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Visual divider for separating sections inside a `field_group/1`.

  Use it without content for a simple divider, or pass inline content when the
  separator should name the next section.

  ## Examples

  ```heex title="Field separator" align="full"
  <.field_separator />
  ```

  ```heex title="Field separator with label" align="full"
  <.field_separator>Advanced options</.field_separator>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def field_separator(assigns) do
    assigns =
      assigns
      |> assign_new(:inner_block, fn -> [] end)
      |> then(fn assigns -> assign(assigns, :has_content, assigns.inner_block != []) end)
      |> assign(:classes, [
        "flex items-center gap-3 text-xs text-muted-foreground",
        assigns.class
      ])
      |> assign(:line_classes, "bg-border h-px flex-1")

    ~H"""
    <div
      :if={@has_content}
      data-slot="field-separator"
      class={classes(@classes)}
      {@rest}
    >
      <div role="separator" aria-orientation="horizontal" class={@line_classes} />
      <span class="shrink-0">{render_slot(@inner_block)}</span>
      <div role="separator" aria-orientation="horizontal" class={@line_classes} />
    </div>
    <div
      :if={!@has_content}
      data-slot="field-separator"
      role="separator"
      aria-orientation="horizontal"
      class={classes(["bg-border h-px w-full", @class])}
      {@rest}
    />
    """
  end
end
