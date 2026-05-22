defmodule CinderUI.Components.Forms.Field do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  doc("""
  Renders a form label.

  ## Examples

      <.label for="email">Email</.label>

      <.label for="project_name">
        Project name
        <span class="text-destructive">*</span>
      </.label>
  """)

  attr :for, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 group-data-[invalid=true]:text-destructive peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        assigns.class
      ])

    ~H"""
    <label data-slot="label" for={@for} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  doc("""
  Field wrapper for label, control, description, and errors.

  `field/1` remains the simplest composition helper. It automatically wraps the
  control passed to its inner block with `field_control/1`, so most usages
  should pass the form control directly and use the `:label`, `:description`,
  `:message`, and `:error` slots for supporting content.

  Prefer the shorthand `:label` slot with `for` for ordinary field labels.
  Reach for raw `:label` slot content, `field_label/1`, `field_control/1`,
  `field_description/1`, `field_message/1`, and `field_error/1` when you need
  richer markup or want to compose the pieces outside `field/1`.

  ## Examples

  ```heex title="Profile field" align="full"
  <.field>
    <:label for="name">Name</:label>
    <.input id="name" name="name" />
    <:description>Shown in your profile.</:description>
  </.field>
  ```

  ```heex title="Validation state" align="full" vrt
  <.field>
    <:label for="email">Work email</:label>
    <.input id="email" name="email" type="email" />
    <:description>We'll send deployment alerts here.</:description>
    <:error>Please use your company domain.</:error>
  </.field>
  ```

  ```heex title="Custom Label Markup" align="full"
  <.field invalid={true}>
    <:label>
      <.field_label>
        <.label for="workspace-slug">Workspace slug</.label>
        <span class="text-muted-foreground text-xs">Used in your public workspace URL.</span>
      </.field_label>
    </:label>
    <.input id="workspace-slug" name="workspace[slug]" value="cinder-ui" />
    <:error>Slug has already been taken.</:error>
  </.field>
  ```

  ```heex title="Phoenix validation flow" align="full" vrt
  <.form for={%{}} phx-change="validate" phx-submit="save" class="space-y-6">
    <.field invalid={true}>
      <:label for="owner">Owner</:label>

      <.autocomplete
        id="owner"
        name="owner"
        value="levi"
        aria-label="Owner"
      >
        <:option value="levi" label="Levi Buzolic" description="Engineering" />
        <:option value="mira" label="Mira Chen" description="Design" />
        <:empty>No matching teammates.</:empty>
      </.autocomplete>

      <:description>Choose the teammate responsible for this workspace.</:description>
      <:error>Please choose a teammate.</:error>
    </.field>
  </.form>
  ```

  ```heex title="Date range fields" align="full"
  <div class="grid gap-4 sm:grid-cols-2">
    <.field>
      <:label for="report_start_date">Start date</:label>
      <.input
        id="report_start_date"
        name="report[start_date]"
        type="date"
        value="2026-06-01"
      />
      <:description>Use the first local day to include in the report.</:description>
    </.field>

    <.field invalid={true}>
      <:label for="report_end_date">End date</:label>
      <.input
        id="report_end_date"
        name="report[end_date]"
        type="date"
        value="2026-05-31"
        min="2026-06-01"
        aria-invalid="true"
      />
      <:error>End date must be on or after the start date.</:error>
    </.field>
  </div>
  ```

  ```heex title="LiveView date validation" align="full" vrt
  <.form for={@form} phx-change="validate" phx-submit="save" class="grid gap-6">
    <.field>
      <:label for={@form[:start_date].id}>Start date</:label>
      <.input field={@form[:start_date]} type="date" required />
      <:description>Changes are validated by the LiveView on phx-change.</:description>
    </.field>

    <.field invalid={true}>
      <:label for={@form[:end_date].id}>End date</:label>
      <.input
        field={@form[:end_date]}
        type="date"
        min="2026-06-01"
        aria-invalid="true"
      />
      <:error>End date must be on or after the start date.</:error>
    </.field>
  </.form>
  ```
  """)

  attr :class, :string, default: nil
  attr :invalid, :boolean, default: false
  attr :rest, :global

  slot :label do
    attr :for, :string
    attr :class, :string
  end

  slot :description
  slot :message
  slot :error
  slot :inner_block, required: true

  def field(assigns) do
    invalid = assigns.invalid || assigns.error != []

    assigns =
      assigns
      |> assign(:invalid, invalid)
      |> assign(:classes, ["group grid gap-3", assigns.class])

    ~H"""
    <div data-slot="field" data-invalid={@invalid} class={classes(@classes)} {@rest}>
      <.field_label :if={@label != []}>
        <.field_label_slot :for={label <- @label} slot={label} />
      </.field_label>
      <.field_control>{render_slot(@inner_block)}</.field_control>
      <.field_description :if={@description != []}>{render_slot(@description)}</.field_description>
      <.field_message :if={@message != []}>{render_slot(@message)}</.field_message>
      <.field_error :if={@error != []}>{render_slot(@error)}</.field_error>
    </div>
    """
  end

  doc("""
  Wraps field labels so shared spacing and invalid-state styling remain
  consistent across controls. Inside `field/1`, provide it via the `:label`
  slot when you need richer label content than a single `label/1`.

  ## Example

  ```heex title="Grouped field label" align="full"
  <.field_label>
    <.label for="workspace_name">Workspace name</.label>
    <span class="text-muted-foreground text-xs">Used across the dashboard.</span>
  </.field_label>
  ```

  ```heex title="Field label in context" align="full"
  <.field>
    <:label>
      <.field_label>
        <.label for="workspace_name">Workspace name</.label>
        <span class="text-muted-foreground text-xs">Shown in team switchers.</span>
      </.field_label>
    </:label>
    <.input id="workspace_name" name="workspace[name]" value="Cinder UI" />
  </.field>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_label(assigns) do
    assigns = assign(assigns, :classes, ["flex flex-col gap-1", assigns.class])

    ~H"""
    <div data-slot="field-label" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  attr :slot, :map, required: true

  defp field_label_slot(assigns) do
    slot = assigns.slot

    assigns =
      assigns
      |> assign(:slot_entry, slot)
      |> assign(:auto_label, direct_label_slot?(slot))
      |> assign(:for, slot[:for])
      |> assign(:class, slot[:class])

    ~H"""
    <.label :if={@auto_label} for={@for} class={@class}>
      {render_slot(@slot_entry)}
    </.label>
    <%= if !@auto_label do %>
      {render_slot(@slot_entry)}
    <% end %>
    """
  end

  doc("""
  Wraps the main interactive control inside a field.

  `field/1` already applies this wrapper around its inner block, so you
  generally do not need to call `field_control/1` inside a normal `field/1`
  example. Use it directly when composing a field manually or when you need to
  attach the invalid-state control styles outside `field/1`.

  ## Example

  ```heex title="Field control wrapper" align="full"
  <.field_control>
    <.input id="workspace_slug" value="cinder-ui" />
  </.field_control>
  ```

  ```heex title="Field control with helper text" align="full"
  <.field>
    <:label for="billing_email">Billing email</:label>
    <.input id="billing_email" name="billing[email]" type="email" placeholder="billing@team.com" />
    <:description>Invoices and payment reminders go here.</:description>
  </.field>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_control(assigns) do
    assigns =
      assign(assigns, :classes, [
        "group-data-[invalid=true]:[&_[data-slot=input]]:border-destructive group-data-[invalid=true]:[&_[data-slot=input]]:ring-destructive/20 group-data-[invalid=true]:[&_[data-slot=number-field-input]]:border-destructive group-data-[invalid=true]:[&_[data-slot=number-field-input]]:ring-destructive/20 group-data-[invalid=true]:[&_[data-slot=textarea]]:border-destructive group-data-[invalid=true]:[&_[data-slot=textarea]]:ring-destructive/20 group-data-[invalid=true]:[&_[data-slot=select-trigger]]:border-destructive group-data-[invalid=true]:[&_[data-slot=native-select]]:border-destructive group-data-[invalid=true]:[&_[data-slot=native-select]]:ring-destructive/20 group-data-[invalid=true]:[&_[data-slot=autocomplete-input]]:border-destructive group-data-[invalid=true]:[&_[data-slot=combobox-input]]:border-destructive group-data-[invalid=true]:[&_[data-slot=switch]]:border-destructive group-data-[invalid=true]:[&_[data-slot=checkbox]]:border-destructive group-data-[invalid=true]:[&_[data-slot=radio-group-item]]:border-destructive",
        assigns.class
      ])

    ~H"""
    <div data-slot="field-control" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Helper text shown beneath a field control.

  In most `field/1` usage, prefer the `:description` slot. Use
  `field_description/1` directly for isolated helper rendering or custom field
  composition.

  ## Example

  ```heex title="Field description" align="full"
  <.field_description>Used in your public workspace URL.</.field_description>
  ```

  ```heex title="Field description in context" align="full"
  <.field>
    <:label for="workspace_slug">Workspace slug</:label>
    <.input id="workspace_slug" name="workspace[slug]" value="cinder-ui" />
    <:description>Used in your public workspace URL.</:description>
  </.field>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_description(assigns) do
    assigns =
      assign(assigns, :classes, ["text-muted-foreground text-sm leading-normal", assigns.class])

    ~H"""
    <p data-slot="field-description" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  doc("""
  Neutral status or informational message shown beneath a field control.

  In most `field/1` usage, prefer the `:message` slot. Use `field_message/1`
  directly for isolated helper rendering or custom field composition.

  ## Example

  ```heex title="Field message" align="full"
  <.field_message>Visible immediately after save.</.field_message>
  ```

  ```heex title="Field message in context" align="full"
  <.field>
    <:label for="project_name">Project name</:label>
    <.input id="project_name" name="project[name]" value="Marketing site refresh" />
    <:message>Saved automatically a few seconds ago.</:message>
  </.field>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_message(assigns) do
    assigns =
      assign(assigns, :classes, ["text-foreground text-sm leading-normal", assigns.class])

    ~H"""
    <p data-slot="field-message" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  doc("""
  Error or validation message shown beneath a field control.

  In most `field/1` usage, prefer the `:error` slot. Use `field_error/1`
  directly for isolated helper rendering or custom field composition.

  ## Example

  ```heex title="Field error" align="full"
  <.field_error>Please use your company domain.</.field_error>
  ```

  ```heex title="Field error in context" align="full"
  <.field invalid={true}>
    <:label for="work_email">Work email</:label>
    <.input id="work_email" name="work_email" type="email" value="hello@gmail.com" />
    <:error>Please use your company domain.</:error>
  </.field>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def field_error(assigns) do
    assigns =
      assign(assigns, :classes, ["text-destructive text-sm font-medium", assigns.class])

    ~H"""
    <p data-slot="field-error" class={classes(@classes)} {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  defp direct_label_slot?(slot) do
    not is_nil(slot[:for]) or not is_nil(slot[:class])
  end
end
