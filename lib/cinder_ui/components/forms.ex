defmodule CinderUI.Components.Forms do
  @moduledoc """
  Form-related components modeled after shadcn/ui.

  Included components:

  - `label/1`
  - `field/1`
  - `field_label/1`
  - `field_control/1`
  - `field_description/1`
  - `field_message/1`
  - `field_error/1`
  - `input/1`
  - `number_field/1`
  - `textarea/1`
  - `checkbox/1`
  - `switch/1`
  - `select/1`
  - `native_select/1`
  - `autocomplete/1`
  - `radio_group/1`
  - `slider/1`
  - `input_group/1`
  - `input_group_addon/1`
  - `input_otp/1`

  ## Interactive docs

  [View live Forms examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#forms).
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  alias CinderUI.Icons
  alias Phoenix.HTML.Form

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

  doc("""
  Renders an input with shadcn classes.

  ## Examples

  ```heex title="Text input" align="full"
  <.input id="email" type="email" placeholder="name@example.com" />
  ```

  ```heex title="With value" align="full"
  <.input id="username" name="username" value="levi" />
  ```

  ### With FormField

      <.input field={@form[:email]} />

  ### With label

      <.input field={@form[:email]} label="Email" />

  ### With explicit errors

      <.input field={@form[:email]} label="Email" errors={["can't be blank"]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:email].id}>Email</:label>
        <.input field={@form[:email]} />
        <:description>We'll send alerts here.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :type, :string, default: "text"
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :placeholder, :string, default: nil
  attr :class, :string, default: nil

  attr :rest, :global,
    include:
      ~w(accept autocomplete disabled max maxlength min minlength pattern readonly required step)

  def input(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:input_classes, [
        text_input_base_classes(),
        "file:text-foreground file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium",
        assigns.class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <input
        id={@id}
        type={@type}
        data-slot="input"
        name={@name}
        value={@value}
        placeholder={@placeholder}
        class={classes(@input_classes)}
        {@rest}
      />
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <input
      :if={!@label && @errors == []}
      id={@id}
      type={@type}
      data-slot="input"
      name={@name}
      value={@value}
      placeholder={@placeholder}
      class={classes(@input_classes)}
      {@rest}
    />
    """
  end

  doc("""
  Renders a number input with increment and decrement controls.

  Keyboard interaction comes from the native `type="number"` input, so arrow
  keys, min/max constraints, and step behavior stay browser-native while the
  buttons provide a touch-friendly affordance.

  ## Examples

  ```heex title="Basic number field" align="full"
  <.number_field id="seat-count" name="seats" value={3} min={1} max={10} />
  ```

  ```heex title="Fractional step" align="full"
  <.number_field id="discount" name="discount" value={1.5} min={0} max={5} step={0.5} />
  ```

  ### With FormField

      <.number_field field={@form[:quantity]} />

  ### With label

      <.number_field field={@form[:quantity]} label="Quantity" />

  ### With explicit errors

      <.number_field field={@form[:quantity]} label="Quantity" errors={["must be positive"]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:quantity].id}>Quantity</:label>
        <.number_field field={@form[:quantity]} />
        <:description>Enter a positive number.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :step, :any, default: 1
  attr :placeholder, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil
  attr :decrement_label, :string, default: "Decrease value"
  attr :increment_label, :string, default: "Increase value"
  attr :rest, :global, include: ~w(autocomplete readonly required inputmode aria-label)

  def number_field(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:id, assigns.id || "cinder-ui-number-field-#{System.unique_integer([:positive])}")
      |> assign(:root_classes, [
        "flex items-center gap-0",
        assigns.class
      ])
      |> assign(:button_classes, [
        "border-input bg-background text-muted-foreground hover:text-foreground inline-flex h-9 w-9 shrink-0 items-center justify-center border shadow-xs transition-colors outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50"
      ])
      |> assign(:input_classes, [
        form_control_base_classes(),
        form_control_state_classes(),
        "dark:bg-input/30 h-9 w-full min-w-0 rounded-none border-y border-x-0 bg-transparent px-3 py-1 text-center text-base md:text-sm",
        "[appearance:textfield] [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none",
        assigns.input_class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <.number_field_control
        id={@id}
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        placeholder={@placeholder}
        disabled={@disabled}
        decrement_label={@decrement_label}
        increment_label={@increment_label}
        root_classes={@root_classes}
        button_classes={@button_classes}
        input_classes={@input_classes}
        rest={@rest}
      />
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <.number_field_control
      :if={!@label && @errors == []}
      id={@id}
      name={@name}
      value={@value}
      min={@min}
      max={@max}
      step={@step}
      placeholder={@placeholder}
      disabled={@disabled}
      decrement_label={@decrement_label}
      increment_label={@increment_label}
      root_classes={@root_classes}
      button_classes={@button_classes}
      input_classes={@input_classes}
      rest={@rest}
    />
    """
  end

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :min, :any, default: nil
  attr :max, :any, default: nil
  attr :step, :any, default: 1
  attr :placeholder, :string, default: nil
  attr :disabled, :boolean, required: true
  attr :decrement_label, :string, required: true
  attr :increment_label, :string, required: true
  attr :root_classes, :list, required: true
  attr :button_classes, :list, required: true
  attr :input_classes, :list, required: true
  attr :rest, :map, required: true

  defp number_field_control(assigns) do
    ~H"""
    <div data-slot="number-field" class={classes(@root_classes)}>
      <button
        type="button"
        data-slot="number-field-decrement"
        aria-label={@decrement_label}
        disabled={@disabled}
        class={classes([@button_classes, "rounded-l-md"])}
        onclick="const input = this.closest('[data-slot=number-field]')?.querySelector('[data-slot=number-field-input]'); if (input) { input.stepDown(); input.dispatchEvent(new Event('input', { bubbles: true })); input.dispatchEvent(new Event('change', { bubbles: true })); input.focus(); }"
      >
        <Icons.icon name="minus" class="size-4" />
      </button>

      <input
        id={@id}
        type="number"
        data-slot="number-field-input"
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        placeholder={@placeholder}
        disabled={@disabled}
        class={classes(@input_classes)}
        {@rest}
      />

      <button
        type="button"
        data-slot="number-field-increment"
        aria-label={@increment_label}
        disabled={@disabled}
        class={classes([@button_classes, "rounded-r-md"])}
        onclick="const input = this.closest('[data-slot=number-field]')?.querySelector('[data-slot=number-field-input]'); if (input) { input.stepUp(); input.dispatchEvent(new Event('input', { bubbles: true })); input.dispatchEvent(new Event('change', { bubbles: true })); input.focus(); }"
      >
        <Icons.icon name="plus" class="size-4" />
      </button>
    </div>
    """
  end

  doc("""
  Renders a textarea with shadcn classes.

  ## Examples

  ```heex title="Basic textarea" align="full"
  <.textarea id="bio" name="bio" rows={4} />
  ```

  ```heex title="With placeholder" align="full"
  <.textarea id="release_notes" name="release_notes" rows={8} placeholder="Summarize what changed in this release..." />
  ```

  ### With FormField

      <.textarea field={@form[:bio]} />

  ### With label

      <.textarea field={@form[:bio]} label="Bio" />

  ### With explicit errors

      <.textarea field={@form[:bio]} label="Bio" errors={["too short"]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:bio].id}>Bio</:label>
        <.textarea field={@form[:bio]} />
        <:description>Tell us about yourself.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 4
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled maxlength minlength readonly required)

  def textarea(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:classes, [
        form_control_base_classes(),
        form_control_state_classes(),
        "placeholder:text-muted-foreground dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md bg-transparent px-3 py-2 text-base md:text-sm",
        assigns.class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <textarea
        id={@id}
        data-slot="textarea"
        name={@name}
        rows={@rows}
        placeholder={@placeholder}
        class={classes(@classes)}
        {@rest}
      ><%= @value %></textarea>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <textarea
      :if={!@label && @errors == []}
      id={@id}
      data-slot="textarea"
      name={@name}
      rows={@rows}
      placeholder={@placeholder}
      class={classes(@classes)}
      {@rest}
    ><%= @value %></textarea>
    """
  end

  doc("""
  Renders a checkbox control with optional inline label content.

  ## Examples

  ```heex title="Basic checkbox" align="full"
  <.checkbox id="terms" name="terms">Accept terms</.checkbox>
  ```

  ```heex title="Checked state" align="full"
  <.checkbox id="updates" name="updates" checked={true}>Notify me about product updates</.checkbox>
  ```

  ### With FormField

      <.checkbox field={@form[:active]} />

  ### With label attr (inline)

      <.checkbox field={@form[:active]} label="Active" />

  ### With inner_block (takes precedence over label attr)

      <.checkbox field={@form[:terms]}>
        I agree to the <a href="/terms">Terms of Service</a>
      </.checkbox>

  ### With explicit errors

      <.checkbox field={@form[:terms]} errors={["must be accepted"]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:active].id}>Active</:label>
        <.checkbox field={@form[:active]} />
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def checkbox(assigns) do
    had_field = not is_nil(assigns[:field])

    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a ->
        if had_field do
          assign(a, :checked, Form.normalize_value("checkbox", a[:value]))
        else
          a
        end
      end)
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:classes, [
        "peer border-input dark:bg-input/30 checked:bg-primary checked:text-primary-foreground checked:border-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive size-4 shrink-0 rounded-[4px] border shadow-xs transition-shadow outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        assigns.class
      ])

    ~H"""
    <div :if={@errors != []} class="space-y-2">
      <label class="inline-flex items-center gap-2">
        <input type="hidden" name={@name} value="false" />
        <input
          id={@id}
          data-slot="checkbox"
          type="checkbox"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          class={classes(@classes)}
          {@rest}
        />
        <span :if={@inner_block != []} class="text-sm text-foreground">
          {render_slot(@inner_block)}
        </span>
        <span :if={@inner_block == [] && @label} class="text-sm text-foreground">
          {@label}
        </span>
      </label>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <label :if={@errors == []} class="inline-flex items-center gap-2">
      <input type="hidden" name={@name} value="false" />
      <input
        id={@id}
        data-slot="checkbox"
        type="checkbox"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class={classes(@classes)}
        {@rest}
      />
      <span :if={@inner_block != []} class="text-sm text-foreground">
        {render_slot(@inner_block)}
      </span>
      <span :if={@inner_block == [] && @label} class="text-sm text-foreground">
        {@label}
      </span>
    </label>
    """
  end

  doc("""
  Renders a switch control with optional label content.

  ## Examples

  ```heex title="Basic switch" align="full"
  <.switch id="marketing" checked={true}>Email updates</.switch>
  ```

  ```heex title="Disabled" align="full"
  <.switch id="notifications" disabled={true}>Push notifications</.switch>
  ```

  ### With FormField

      <.switch field={@form[:notifications]} />

  ### With label attr (inline)

      <.switch field={@form[:notifications]} label="Enable notifications" />

  ### With inner_block (takes precedence over label attr)

      <.switch field={@form[:notifications]}>
        Enable <strong>push</strong> notifications
      </.switch>

  ### With explicit errors

      <.switch field={@form[:notifications]} errors={["is required"]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:notifications].id}>Notifications</:label>
        <.switch field={@form[:notifications]} />
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :disabled, :boolean, default: false
  attr :size, :atom, default: :default, values: [:sm, :default]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def switch(assigns) do
    had_field = not is_nil(assigns[:field])

    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a ->
        if had_field do
          assign(a, :checked, Form.normalize_value("checkbox", a[:value]))
        else
          a
        end
      end)
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)

    state = if(assigns.checked, do: "checked", else: "unchecked")

    root_size =
      case assigns.size do
        :sm -> "h-3.5 w-6"
        :default -> "h-[1.15rem] w-8"
      end

    thumb_size =
      case assigns.size do
        :sm -> "size-3"
        :default -> "size-4"
      end

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:root_size, root_size)
      |> assign(:thumb_size, thumb_size)
      |> assign(:thumb_position, "peer-checked:translate-x-[calc(100%-2px)]")
      |> assign(:track_classes, [
        "peer appearance-none bg-input checked:bg-primary focus-visible:border-ring focus-visible:ring-ring/50 dark:bg-input/80 dark:checked:bg-primary inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        root_size,
        assigns.class
      ])

    ~H"""
    <label class="inline-flex items-center gap-2">
      <input type="hidden" name={@name} value="false" />
      <span class="relative inline-flex items-center">
        <input
          id={@id}
          data-slot="switch"
          type="checkbox"
          role="switch"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          data-size={@size}
          data-state={@state}
          class={classes(@track_classes)}
          {@rest}
        />
        <span
          data-slot="switch-thumb"
          class={
            classes([
              "pointer-events-none absolute left-[1px] block rounded-full bg-background dark:peer-not-checked:bg-foreground dark:peer-checked:bg-primary-foreground ring-0 transition-transform peer-not-checked:translate-x-0",
              @thumb_size,
              @thumb_position
            ])
          }
        />
      </span>
      <span :if={@inner_block != []} class="text-sm text-foreground">
        {render_slot(@inner_block)}
      </span>
      <span :if={@inner_block == [] && @label} class="text-sm text-foreground">
        {@label}
      </span>
    </label>
    """
  end

  doc("""
  Renders a custom select with a button trigger and listbox content.

  Use `native_select/1` when you specifically want a plain HTML `<select>`.

  ## Examples

  ```heex title="Custom select" align="full"
  <.select id="team-plan" name="plan" value="pro">
    <:option value="free" label="Free" />
    <:option value="pro" label="Pro" />
    <:option value="enterprise" label="Enterprise" />
  </.select>
  ```

  ```heex title="Grouped labels" align="full" vrt
  <.select id="assignee" name="assignee" placeholder="Assign a teammate">
    <:option value="levi" label="Levi" description="Platform" group="Engineering" />
    <:option value="mira" label="Mira" description="Product Design" group="Design" />
  </.select>
  ```

  ```heex title="Disabled option" align="full" vrt
  <.select id="region" name="region">
    <:option value="us" label="United States" />
    <:option value="eu" label="Europe" />
    <:option value="apac" label="APAC" disabled={true} />
  </.select>
  ```

  ```heex title="Clearable select" align="full" vrt
  <.select id="support-tier" name="tier" value="pro" clearable={true}>
    <:option value="free" label="Free" />
    <:option value="pro" label="Pro" />
  </.select>
  ```

  ### With FormField

      <.select field={@form[:role]}>
        <:option value="admin" label="Admin" />
        <:option value="member" label="Member" />
      </.select>

  ### With label

      <.select field={@form[:role]} label="Role">
        <:option value="admin" label="Admin" />
        <:option value="member" label="Member" />
      </.select>

  ### With explicit errors

      <.select field={@form[:role]} label="Role" errors={["is required"]}>
        <:option value="admin" label="Admin" />
      </.select>

  ### Inside field composition

      <.field>
        <:label for={@form[:role].id}>Role</:label>
        <.select field={@form[:role]}>
          <:option value="admin" label="Admin" />
        </.select>
        <:description>Choose your access level.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :placeholder, :string, default: "Choose an option"
  attr :disabled, :boolean, default: false
  attr :clearable, :boolean, default: false
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  attr :rest, :global, include: ~w(required aria-label)

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
    attr :description, :string
    attr :disabled, :boolean
    attr :group, :string
  end

  slot :empty

  def select(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:id, assigns.id || "cinder-ui-select-#{System.unique_integer([:positive])}")

    selected_option = selected_option(assigns.option, assigns.value)
    selected_label = if selected_option, do: selected_option.label, else: assigns.placeholder

    assigns =
      assigns
      |> assign(:selected_label, selected_label)
      |> assign(:selected_value, selected_option && selected_option.value)
      |> assign(:root_classes, ["relative w-full", assigns.class])
      |> assign(:trigger_classes, [
        "border-input bg-background text-foreground flex h-9 w-full items-center justify-between rounded-md border px-3 py-2 text-sm shadow-xs outline-none transition-[color,box-shadow] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        assigns.clearable && "pr-16",
        !selected_option && "text-muted-foreground"
      ])
      |> assign(:content_classes, [
        "bg-popover text-popover-foreground absolute top-full left-0 z-50 mt-2 hidden max-h-72 w-full overflow-y-auto rounded-md border p-1 shadow-md outline-none",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        assigns.content_class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <.select_control
        id={@id}
        name={@name}
        value={@value}
        selected_label={@selected_label}
        selected_value={@selected_value}
        placeholder={@placeholder}
        disabled={@disabled}
        clearable={@clearable}
        option={@option}
        empty={@empty}
        root_classes={@root_classes}
        trigger_classes={@trigger_classes}
        content_classes={@content_classes}
        rest={@rest}
      />
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <.select_control
      :if={!@label && @errors == []}
      id={@id}
      name={@name}
      value={@value}
      selected_label={@selected_label}
      selected_value={@selected_value}
      placeholder={@placeholder}
      disabled={@disabled}
      clearable={@clearable}
      option={@option}
      empty={@empty}
      root_classes={@root_classes}
      trigger_classes={@trigger_classes}
      content_classes={@content_classes}
      rest={@rest}
    />
    """
  end

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :selected_label, :string, required: true
  attr :selected_value, :string, default: nil
  attr :placeholder, :string, required: true
  attr :disabled, :boolean, required: true
  attr :clearable, :boolean, required: true
  attr :root_classes, :list, required: true
  attr :trigger_classes, :list, required: true
  attr :content_classes, :list, required: true
  attr :rest, :map, required: true
  attr :option, :list, required: true
  attr :empty, :list, default: []

  defp select_control(assigns) do
    ~H"""
    <div
      id={@id}
      data-slot="select"
      data-state="closed"
      data-placeholder={@placeholder}
      class={classes(@root_classes)}
      phx-hook="CuiSelect"
    >
      <input
        :if={@name}
        data-slot="select-input"
        type="hidden"
        name={@name}
        value={@selected_value}
        disabled={@disabled}
      />

      <button
        type="button"
        data-slot="select-trigger"
        data-select-trigger
        aria-haspopup="listbox"
        aria-expanded="false"
        aria-controls={"#{@id}-content"}
        aria-activedescendant=""
        disabled={@disabled}
        class={classes(@trigger_classes)}
        {@rest}
      >
        <span data-slot="select-value" class="truncate">{@selected_label}</span>
        <CinderUI.Icons.icon
          name="chevron-down"
          class="text-muted-foreground ml-2 size-4 shrink-0"
          aria-hidden="true"
        />
      </button>

      <button
        :if={@clearable}
        type="button"
        data-slot="select-clear"
        data-select-clear
        aria-label="Clear selection"
        class={
          classes([
            "text-muted-foreground hover:text-foreground absolute top-1/2 right-8 -translate-y-1/2 rounded-xs",
            !@selected_value && "hidden"
          ])
        }
      >
        <Icons.icon name="x" class="size-3.5" />
      </button>

      <div
        id={"#{@id}-content"}
        data-slot="select-content"
        data-select-content
        role="listbox"
        tabindex="-1"
        class={classes(@content_classes)}
      >
        <div
          :for={group <- grouped_options(@option)}
          :if={@option != []}
          data-slot="select-group"
          class="py-1"
        >
          <div
            :if={group.label}
            data-slot="select-group-label"
            class="text-muted-foreground px-2 py-1 text-xs font-medium"
          >
            {group.label}
          </div>

          <button
            :for={{option, index} <- group.options}
            id={"#{@id}-option-#{index}"}
            type="button"
            role="option"
            data-slot="select-item"
            data-select-item
            data-value={option.value}
            data-label={option.label}
            data-disabled={option[:disabled] || false}
            data-selected={@value == option.value}
            aria-selected={@value == option.value}
            disabled={option[:disabled] || false}
            class={
              classes([
                "relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-left text-sm outline-hidden select-none",
                "data-[highlighted=true]:bg-accent data-[highlighted=true]:text-accent-foreground",
                "data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50"
              ])
            }
          >
            <span class="min-w-0 flex-1">
              <span class="block truncate">{option.label}</span>
              <span :if={option[:description]} class="text-muted-foreground block text-xs">
                {option.description}
              </span>
            </span>
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

        <div
          :if={@option == []}
          data-slot="select-empty"
          class="text-muted-foreground px-2 py-1.5 text-sm"
        >
          {if @empty != [], do: render_slot(@empty), else: "No options available."}
        </div>
      </div>
    </div>
    """
  end

  doc("""
  Renders a native `<select>` element with shadcn styles.

  Use this when you want platform-native select behavior rather than the custom
  listbox UI from `select/1`.

  ## Examples

  ```heex title="Native select" align="full"
  <.native_select name="framework" value="phoenix">
    <:option value="phoenix" label="Phoenix" />
    <:option value="rails" label="Rails" />
    <:option value="laravel" label="Laravel" />
  </.native_select>
  ```

  ```heex title="With placeholder" align="full"
  <.native_select name="assignee" placeholder="Assign a teammate">
    <:option value="levi" label="Levi" />
    <:option value="juz" label="Justin" />
  </.native_select>
  ```

  ### With FormField (using options attr)

      <.native_select field={@form[:role]} options={[{"Admin", "admin"}, {"Member", "member"}]} />

  ### With FormField (using option slots)

      <.native_select field={@form[:role]}>
        <:option value="admin" label="Admin" />
        <:option value="member" label="Member" />
      </.native_select>

  ### With label

      <.native_select field={@form[:role]} label="Role" options={[{"Admin", "admin"}]} />

  ### With explicit errors

      <.native_select field={@form[:role]} label="Role" errors={["is required"]} options={[{"Admin", "admin"}]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:role].id}>Role</:label>
        <.native_select field={@form[:role]} options={[{"Admin", "admin"}]} />
        <:description>Choose your access level.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :options, :list, default: nil
  attr :placeholder, :string, default: "Choose an option"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :option do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def native_select(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:classes, [
        text_input_base_classes(),
        "appearance-none pr-8 select-none",
        assigns.class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <div
        data-slot="native-select-wrapper"
        class="group/native-select relative w-full has-[select:disabled]:opacity-50"
      >
        <select id={@id} data-slot="native-select" name={@name} class={classes(@classes)} {@rest}>
          <option :if={is_nil(@value)} value="" disabled selected>{@placeholder}</option>
          <%= if @option != [] do %>
            <option :for={option <- @option} value={option.value} selected={@value == option.value}>
              {option.label}
            </option>
          <% else %>
            {Form.options_for_select(@options || [], @value)}
          <% end %>
        </select>
        <CinderUI.Icons.icon
          name="chevron-down"
          class="text-muted-foreground pointer-events-none absolute top-1/2 right-3 size-4 -translate-y-1/2 select-none"
          aria-hidden="true"
        />
      </div>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <div
      :if={!@label && @errors == []}
      data-slot="native-select-wrapper"
      class="group/native-select relative w-full has-[select:disabled]:opacity-50"
    >
      <select id={@id} data-slot="native-select" name={@name} class={classes(@classes)} {@rest}>
        <option :if={is_nil(@value)} value="" disabled selected>{@placeholder}</option>
        <%= if @option != [] do %>
          <option :for={option <- @option} value={option.value} selected={@value == option.value}>
            {option.label}
          </option>
        <% else %>
          {Form.options_for_select(@options || [], @value)}
        <% end %>
      </select>
      <CinderUI.Icons.icon
        name="chevron-down"
        class="text-muted-foreground pointer-events-none absolute top-1/2 right-3 size-4 -translate-y-1/2 select-none"
        aria-hidden="true"
      />
    </div>
    """
  end

  doc("""
  Renders a filterable autocomplete input backed by a hidden form value.

  This is intended for searching and selecting from a known set of options. Use
  `select/1` when you want a trigger-driven listbox instead of a text input.

  ## When to use it

  Use `autocomplete/1` when the person typing should search by label, but the
  form needs to submit a separate stable value through the hidden input.

  Prefer `combobox/1` for simpler label-in/label-out filtering where the typed
  text itself is the selected value and you do not need a separate hidden form
  field.

  For server-backed search, keep the current query in LiveView assigns and
  update the option list on `phx-change` or `phx-input`. The component keeps
  its hidden value form-friendly while the visible input remains a normal text
  field that can participate in debounced LiveView events.

  ## Examples

  ```heex title="Autocomplete" align="full"
  <.autocomplete id="team-owner" name="owner" value="levi">
    <:option value="levi" label="Levi Buzolic" description="Engineering" />
    <:option value="mira" label="Mira Chen" description="Design" />
    <:option value="sam" label="Sam Hall" description="Operations" />
  </.autocomplete>
  ```

  ```heex title="Loading state" align="full" vrt
  <.autocomplete id="repo-search" name="repo" loading={true}>
    <:option value="cinder" label="cinder_ui" />
  </.autocomplete>
  ```

  ```heex title="LiveView server search" align="full" vrt
  <.form for={%{}} phx-change="search-owners">
    <.autocomplete
      id="owner-search"
      name="owner"
      value="mira"
      placeholder="Search teammates..."
      loading={false}
      phx-debounce="300"
      aria-label="Search owners"
    >
      <:option value="levi" label="Levi Buzolic" />
      <:option value="mira" label="Mira Chen" />
      <:empty>No teammates match the current query.</:empty>
    </.autocomplete>
  </.form>
  ```

  ### With FormField

      <.autocomplete field={@form[:owner]}>
        <:option value="levi" label="Levi Buzolic" />
        <:option value="mira" label="Mira Chen" />
      </.autocomplete>

  ### With label

      <.autocomplete field={@form[:owner]} label="Owner">
        <:option value="levi" label="Levi Buzolic" />
      </.autocomplete>

  ### With explicit errors

      <.autocomplete field={@form[:owner]} label="Owner" errors={["is required"]}>
        <:option value="levi" label="Levi Buzolic" />
      </.autocomplete>

  ### Inside field composition

      <.field>
        <:label for={@form[:owner].id}>Owner</:label>
        <.autocomplete field={@form[:owner]}>
          <:option value="levi" label="Levi Buzolic" />
        </.autocomplete>
        <:description>Assign a teammate to this project.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :placeholder, :string, default: "Search options..."
  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :loading_text, :string, default: "Loading..."
  attr :class, :string, default: nil
  attr :content_class, :string, default: nil
  attr :rest, :global, include: ~w(required aria-label)

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
    attr :description, :string
    attr :disabled, :boolean
  end

  slot :empty

  def autocomplete(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:id, assigns.id || "cinder-ui-autocomplete-#{System.unique_integer([:positive])}")

    selected_option = selected_option(assigns.option, assigns.value)
    selected_label = if selected_option, do: selected_option.label, else: ""

    assigns =
      assigns
      |> assign(:selected_label, selected_label)
      |> assign(:root_classes, ["relative w-full", assigns.class])
      |> assign(:input_classes, [
        "border-input bg-background text-foreground h-9 w-full rounded-md border px-3 py-2 text-sm shadow-xs outline-none transition-[color,box-shadow] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
        "placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
      ])
      |> assign(:content_classes, [
        "bg-popover text-popover-foreground absolute top-full left-0 z-50 mt-2 hidden max-h-72 w-full overflow-y-auto rounded-md border p-1 shadow-md outline-none",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        assigns.content_class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <.autocomplete_control
        id={@id}
        name={@name}
        value={@value}
        selected_label={@selected_label}
        placeholder={@placeholder}
        disabled={@disabled}
        loading={@loading}
        loading_text={@loading_text}
        option={@option}
        empty={@empty}
        root_classes={@root_classes}
        input_classes={@input_classes}
        content_classes={@content_classes}
        rest={@rest}
      />
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <.autocomplete_control
      :if={!@label && @errors == []}
      id={@id}
      name={@name}
      value={@value}
      selected_label={@selected_label}
      placeholder={@placeholder}
      disabled={@disabled}
      loading={@loading}
      loading_text={@loading_text}
      option={@option}
      empty={@empty}
      root_classes={@root_classes}
      input_classes={@input_classes}
      content_classes={@content_classes}
      rest={@rest}
    />
    """
  end

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :selected_label, :string, required: true
  attr :placeholder, :string, required: true
  attr :disabled, :boolean, required: true
  attr :loading, :boolean, required: true
  attr :loading_text, :string, required: true
  attr :root_classes, :list, required: true
  attr :input_classes, :list, required: true
  attr :content_classes, :list, required: true
  attr :rest, :map, required: true
  attr :option, :list, required: true
  attr :empty, :list, default: []

  defp autocomplete_control(assigns) do
    ~H"""
    <div
      id={@id}
      data-slot="autocomplete"
      data-state="closed"
      data-selected-label={@selected_label}
      data-loading={@loading}
      class={classes(@root_classes)}
      phx-hook="CuiAutocomplete"
    >
      <input
        :if={@name}
        data-slot="autocomplete-value"
        type="hidden"
        name={@name}
        value={@value}
        disabled={@disabled}
      />

      <input
        data-slot="autocomplete-input"
        data-autocomplete-input
        type="text"
        value={@selected_label}
        placeholder={@placeholder}
        autocomplete="off"
        role="combobox"
        aria-autocomplete="list"
        aria-controls={"#{@id}-content"}
        aria-expanded="false"
        aria-activedescendant=""
        disabled={@disabled}
        class={classes(@input_classes)}
        {@rest}
      />

      <div
        id={"#{@id}-content"}
        data-slot="autocomplete-content"
        data-autocomplete-content
        role="listbox"
        tabindex="-1"
        class={classes(@content_classes)}
      >
        <div
          :if={@loading}
          data-slot="autocomplete-loading"
          class="text-muted-foreground px-2 py-1.5 text-sm"
        >
          {@loading_text}
        </div>

        <button
          :for={{option, index} <- Enum.with_index(@option)}
          id={"#{@id}-autocomplete-option-#{index}"}
          type="button"
          role="option"
          data-slot="autocomplete-item"
          data-autocomplete-item
          data-value={option.value}
          data-label={option.label}
          data-disabled={option[:disabled] || false}
          data-selected={@value == option.value}
          aria-selected={@value == option.value}
          disabled={option[:disabled] || false}
          class={
            classes([
              "relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-left text-sm outline-hidden select-none",
              "data-[highlighted=true]:bg-accent data-[highlighted=true]:text-accent-foreground",
              "data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50"
            ])
          }
        >
          <span class="min-w-0 flex-1">
            <span class="block truncate">{option.label}</span>
            <span :if={option[:description]} class="text-muted-foreground block text-xs">
              {option.description}
            </span>
          </span>
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

        <div
          data-slot="autocomplete-empty"
          class="text-muted-foreground hidden px-2 py-1.5 text-sm"
        >
          {if @empty != [], do: render_slot(@empty), else: "No results found."}
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

  doc("""
  Renders a radio group with native radio inputs.

  ## Examples

  ```heex title="Basic radio group" align="full"
  <.radio_group name="plan" value="pro">
    <:option value="free" label="Free" />
    <:option value="pro" label="Pro" />
  </.radio_group>
  ```

  ```heex title="With disabled option" align="full"
  <.radio_group name="region" value="us">
    <:option value="us" label="United States" />
    <:option value="eu" label="Europe" disabled={true} />
  </.radio_group>
  ```

  ### With FormField

      <.radio_group field={@form[:plan]}>
        <:option value="free" label="Free" />
        <:option value="pro" label="Pro" />
      </.radio_group>

  ### With label (renders as fieldset/legend, not label/for)

      <.radio_group field={@form[:plan]} label="Choose a plan">
        <:option value="free" label="Free" />
        <:option value="pro" label="Pro" />
      </.radio_group>

  ### With explicit errors

      <.radio_group field={@form[:plan]} label="Choose a plan" errors={["is required"]}>
        <:option value="free" label="Free" />
        <:option value="pro" label="Pro" />
      </.radio_group>

  ### Inside field composition

      <.field>
        <:label for={@form[:plan].id}>Plan</:label>
        <.radio_group field={@form[:plan]}>
          <:option value="free" label="Free" />
          <:option value="pro" label="Pro" />
        </.radio_group>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
    attr :disabled, :boolean
  end

  def radio_group(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:classes, ["grid gap-3", assigns.class])

    ~H"""
    <fieldset :if={@label || @errors != []}>
      <legend :if={@label} class="text-sm font-medium leading-none mb-3">{@label}</legend>
      <div data-slot="radio-group" role="radiogroup" class={classes(@classes)}>
        <label
          :for={option <- @option}
          class={
            classes(["inline-flex items-center gap-2 text-sm", option[:disabled] && "opacity-50"])
          }
        >
          <input
            data-slot="radio-group-item"
            type="radio"
            name={@name}
            value={option.value}
            checked={@value == option.value}
            disabled={option[:disabled] || false}
            class="border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50"
            {@rest}
          />
          <span>{option.label}</span>
        </label>
      </div>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </fieldset>
    <div
      :if={!@label && @errors == []}
      data-slot="radio-group"
      role="radiogroup"
      class={classes(@classes)}
    >
      <label
        :for={option <- @option}
        class={classes(["inline-flex items-center gap-2 text-sm", option[:disabled] && "opacity-50"])}
      >
        <input
          data-slot="radio-group-item"
          type="radio"
          name={@name}
          value={option.value}
          checked={@value == option.value}
          disabled={option[:disabled] || false}
          class="border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50"
          {@rest}
        />
        <span>{option.label}</span>
      </label>
    </div>
    """
  end

  doc("""
  Renders a slider using native range input(s).

  Use `min`, `max`, and `step` for scalar values. For range sliders, render two
  controls and sync values in LiveView.

  ## Examples

  ```heex title="Basic slider" align="full"
  <.slider id="volume" name="volume" value={45} min={0} max={100} step={1} />
  ```

  ```heex title="CPU limit slider" align="full"
  <.slider id="cpu_limit" name="cpu_limit" value={2} min={1} max={8} step={1} />
  ```

  ### With FormField

      <.slider field={@form[:volume]} />

  ### With label

      <.slider field={@form[:volume]} label="Volume" />

  ### With explicit errors

      <.slider field={@form[:volume]} label="Volume" errors={["is required"]} />

  ### Inside field composition

      <.field>
        <:label for={@form[:volume].id}>Volume</:label>
        <.slider field={@form[:volume]} />
        <:description>Drag to adjust volume level.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: 0
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :min, :any, default: 0
  attr :max, :any, default: 100
  attr :step, :any, default: 1
  attr :class, :string, default: nil
  attr :rest, :global

  def slider(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:classes, [
        "accent-primary h-2 w-full cursor-pointer appearance-none rounded-full bg-primary/20",
        assigns.class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <input
        id={@id}
        data-slot="slider"
        type="range"
        name={@name}
        value={@value}
        min={@min}
        max={@max}
        step={@step}
        class={classes(@classes)}
        {@rest}
      />
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <input
      :if={!@label && @errors == []}
      id={@id}
      data-slot="slider"
      type="range"
      name={@name}
      value={@value}
      min={@min}
      max={@max}
      step={@step}
      class={classes(@classes)}
      {@rest}
    />
    """
  end

  doc("""
  Wraps an input and sibling controls (buttons/icons) in a single inline group.

  Use `input_group_addon/1` for static text, icons, status copy, or other
  non-interactive content that should visually attach to the grouped controls.

  ## Examples

  ```heex title="Search with action" align="full"
  <.input_group>
    <.input placeholder="Search" />
    <.button variant={:secondary} size={:xs}>Go</.button>
  </.input_group>
  ```

  ```heex title="Handle input" align="full"
  <.input_group>
    <.input_group_addon>@</.input_group_addon>
    <.input placeholder="organization" />
  </.input_group>
  ```

  ```heex title="URL builder" align="full"
  <.input_group>
    <.input_group_addon>https://</.input_group_addon>
    <.input value="cinder-ui" />
    <.input_group_addon>.com</.input_group_addon>
  </.input_group>
  ```

  ```heex title="Command search" align="full"
  <.input_group>
    <.input_group_addon>
      <.icon name="search" class="size-4" />
    </.input_group_addon>
    <.input placeholder="Search components" />
    <.input_group_addon>
      <.kbd>⌘K</.kbd>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Loading state" align="full"
  <.input_group>
    <.input placeholder="Generating invite link..." disabled />
    <.input_group_addon>
      <.spinner class="size-4" />
      <span>Syncing</span>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Select + input" align="full"
  <.input_group>
    <.native_select name="team-role" value="admin" class="w-32" aria-label="Team role">
      <:option value="admin" label="Admin" />
      <:option value="editor" label="Editor" />
      <:option value="viewer" label="Viewer" />
    </.native_select>
    <.input placeholder="email@example.com" type="email" class="flex-1" />
  </.input_group>
  ```

  ```heex title="Textarea with footer action" align="full"
  <.input_group align={:block_end}>
    <.textarea
      rows={3}
      placeholder="Write a comment..."
      class="min-h-[5.5rem]"
    />
    <.input_group_addon align={:block_end}>
      <span>0/280</span>
      <.button size={:sm}>Post</.button>
    </.input_group_addon>
  </.input_group>
  ```

  ```heex title="Copy URL action" align="full"
  <.input_group>
    <.input placeholder="https://example.com" />
    <.button variant={:outline} size={:sm}>Copy</.button>
  </.input_group>
  ```
  """)

  attr :align, :atom, default: :inline, values: [:inline, :block_end]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def input_group(assigns) do
    assigns =
      assigns
      |> assign(:align_attr, if(assigns.align == :block_end, do: "block-end", else: "inline"))
      |> assign(:classes, [
        "dark:bg-input/30 relative flex w-full min-w-0 overflow-hidden rounded-md border border-input bg-transparent shadow-xs transition-[color,box-shadow]",
        assigns.align == :inline && "h-9 items-center",
        assigns.align == :block_end && "min-h-9 flex-col items-stretch",
        "has-[:focus-visible]:border-ring has-[:focus-visible]:ring-ring/50 has-[:focus-visible]:ring-[3px]",
        "[&>*]:relative [&>*]:min-w-0 [&>*]:focus-visible:z-10",
        assigns.align == :inline &&
          "[&>*:first-child]:rounded-l-md [&>*:last-child]:rounded-r-md [&>*:only-child]:rounded-md",
        assigns.align == :inline &&
          "[&>*:not(:last-child)]:border-r [&>*:not(:last-child)]:border-input",
        "[&>[data-slot=input-group-addon]]:text-muted-foreground [&>[data-slot=input-group-addon]]:inline-flex [&>[data-slot=input-group-addon]]:shrink-0 [&>[data-slot=input-group-addon]]:items-center [&>[data-slot=input-group-addon]]:justify-center [&>[data-slot=input-group-addon]]:gap-2 [&>[data-slot=input-group-addon]]:text-sm",
        assigns.align == :inline &&
          "[&>[data-slot=input-group-addon]]:h-full [&>[data-slot=input-group-addon]]:px-3 [&>[data-slot=input-group-addon]]:leading-none",
        assigns.align == :block_end &&
          "[&>[data-slot=input-group-addon][data-align=block-end]]:w-full [&>[data-slot=input-group-addon][data-align=block-end]]:items-center [&>[data-slot=input-group-addon][data-align=block-end]]:justify-between [&>[data-slot=input-group-addon][data-align=block-end]]:border-t [&>[data-slot=input-group-addon][data-align=block-end]]:border-input [&>[data-slot=input-group-addon][data-align=block-end]]:bg-muted/20 [&>[data-slot=input-group-addon][data-align=block-end]]:px-3 [&>[data-slot=input-group-addon][data-align=block-end]]:py-2",
        "[&>[data-slot=input]]:h-full [&>[data-slot=input]]:flex-1 [&>[data-slot=input]]:rounded-none [&>[data-slot=input]]:border-0 [&>[data-slot=input]]:bg-transparent [&>[data-slot=input]]:px-3 [&>[data-slot=input]]:py-1 [&>[data-slot=input]]:shadow-none [&>[data-slot=input]]:focus-visible:ring-0",
        "[&>[data-slot=textarea]]:min-h-[5.5rem] [&>[data-slot=textarea]]:w-full [&>[data-slot=textarea]]:rounded-none [&>[data-slot=textarea]]:border-0 [&>[data-slot=textarea]]:bg-transparent [&>[data-slot=textarea]]:px-3 [&>[data-slot=textarea]]:py-3 [&>[data-slot=textarea]]:shadow-none [&>[data-slot=textarea]]:focus-visible:ring-0",
        "[&>[data-slot=select]]:min-w-0 [&>[data-slot=select]]:shrink-0 [&>[data-slot=select]_[data-slot=select-trigger]]:h-full [&>[data-slot=select]_[data-slot=select-trigger]]:rounded-none [&>[data-slot=select]_[data-slot=select-trigger]]:border-0 [&>[data-slot=select]_[data-slot=select-trigger]]:bg-transparent [&>[data-slot=select]_[data-slot=select-trigger]]:px-3 [&>[data-slot=select]_[data-slot=select-trigger]]:py-2 [&>[data-slot=select]_[data-slot=select-trigger]]:shadow-none [&>[data-slot=select]_[data-slot=select-trigger]]:focus-visible:ring-0",
        "[&>[data-slot=native-select-wrapper]]:min-w-0 [&>[data-slot=native-select-wrapper]]:shrink-0 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:h-full [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:rounded-none [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:border-0 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:bg-transparent [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:px-3 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:py-2 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:shadow-none [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:focus-visible:ring-0 [&>[data-slot=native-select-wrapper]_[data-slot=native-select]]:pr-8 [&>[data-slot=native-select-wrapper]_.lucide-chevron-down]:right-3",
        "[&>[data-slot=button]]:h-6 [&>[data-slot=button]]:self-center [&>[data-slot=button]]:rounded-[calc(var(--radius)-5px)] [&>[data-slot=button]]:border-0 [&>[data-slot=button]]:px-2 [&>[data-slot=button]]:text-sm [&>[data-slot=button]]:shadow-none [&>[data-slot=button]]:focus-visible:ring-0",
        "[&>[data-slot=input-group-addon][data-align=block-end]_[data-slot=button]]:h-8 [&>[data-slot=input-group-addon][data-align=block-end]_[data-slot=button]]:self-auto [&>[data-slot=input-group-addon][data-align=block-end]_[data-slot=button]]:px-3",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-group" data-align={@align_attr} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Non-interactive text/icon/status segment used inside `input_group/1`.

  This is useful for prefixes, suffixes, inline status, and small utility
  content that should attach to the surrounding grouped field.

  ## Example

  ```heex title="Input group addon" align="full"
  <.input_group>
    <.input_group_addon>
      <.icon name="mail" class="size-4" />
    </.input_group_addon>
    <.input type="email" placeholder="team@example.com" />
  </.input_group>
  ```
  """)

  attr :align, :atom, default: :inline, values: [:inline, :block_end]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def input_group_addon(assigns) do
    assigns =
      assigns
      |> assign(:align_attr, if(assigns.align == :block_end, do: "block-end", else: "inline"))
      |> assign(:classes, [
        "inline-flex items-center gap-2 whitespace-nowrap bg-transparent",
        assigns.align == :block_end && "whitespace-normal",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-group-addon" data-align={@align_attr} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Renders an OTP-style segmented input layout.

  This component renders one input per position and can be wired using standard
  Phoenix input names such as `code[]`. The bundled `CuiInputOtp` hook adds
  auto-advance, backspace-to-previous, and paste distribution behavior.

  ## Examples

  ```heex title="Basic OTP input" align="full"
  <.input_otp name="verification_code[]" length={6} />
  ```

  ```heex title="With grouped separators" align="full"
  <.input_otp name="backup_code[]" length={6} groups={[3, 3]} values={["1", "2", "3", "4", "5", "6"]} />
  ```

  ### With FormField (string value is split into individual cells)

      <.input_otp field={@form[:code]} length={6} />

  ### With label

      <.input_otp field={@form[:code]} label="Verification code" length={6} />

  ### With explicit errors

      <.input_otp field={@form[:code]} label="Verification code" errors={["is invalid"]} length={6} />

  ### Inside field composition

      <.field>
        <:label for={@form[:code].id}>Verification code</:label>
        <.input_otp field={@form[:code]} length={6} />
        <:description>Enter the 6-digit code from your email.</:description>
      </.field>
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: "code[]"
  attr :length, :integer, default: 6
  attr :values, :list, default: []
  attr :groups, :list, default: []
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :label, :string, default: nil
  attr :errors, :list, default: nil
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil
  attr :rest, :global

  def input_otp(assigns) do
    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> then(fn a ->
        if is_binary(a[:value]) && a[:values] == [] do
          assign(a, :values, String.graphemes(a.value || ""))
        else
          a
        end
      end)
      |> assign(:id, assigns.id || "cinder-ui-input-otp-#{System.unique_integer([:positive])}")
      |> assign(:separator_indexes, input_otp_separator_indexes(assigns.groups, assigns.length))
      |> assign(:classes, [
        "flex items-center gap-2",
        assigns.class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <div id={@id} data-slot="input-otp" class={classes(@classes)} phx-hook="CuiInputOtp">
        <.input_otp_cell
          :for={index <- Enum.to_list(0..(@length - 1))}
          index={index}
          name={@name}
          value={Enum.at(@values, index, "")}
          input_class={@input_class}
          extra_attrs={@rest}
          show_separator={index in @separator_indexes}
        />
      </div>
      <.field_error :for={msg <- @errors}>{msg}</.field_error>
    </div>
    <div
      :if={!@label && @errors == []}
      id={@id}
      data-slot="input-otp"
      class={classes(@classes)}
      phx-hook="CuiInputOtp"
    >
      <.input_otp_cell
        :for={index <- Enum.to_list(0..(@length - 1))}
        index={index}
        name={@name}
        value={Enum.at(@values, index, "")}
        input_class={@input_class}
        extra_attrs={@rest}
        show_separator={index in @separator_indexes}
      />
    </div>
    """
  end

  attr :index, :integer, required: true
  attr :name, :string, required: true
  attr :value, :string, default: ""
  attr :input_class, :string, default: nil
  attr :show_separator, :boolean, required: true
  attr :extra_attrs, :any, default: %{}

  defp input_otp_cell(assigns) do
    ~H"""
    <input
      data-input-otp-input
      data-input-otp-index={@index}
      type="text"
      inputmode="numeric"
      pattern="[0-9]*"
      maxlength="1"
      name={@name}
      value={@value}
      class={
        classes([
          "border-input focus-visible:border-ring focus-visible:ring-ring/50 h-10 w-10 rounded-md border bg-transparent text-center text-sm shadow-xs outline-none focus-visible:ring-[3px]",
          @input_class
        ])
      }
      {@extra_attrs}
    />
    <span
      :if={@show_separator}
      data-slot="input-otp-separator"
      data-input-otp-separator-after={@index}
      class="text-muted-foreground text-sm"
    >
      -
    </span>
    """
  end

  defp text_input_base_classes do
    [
      form_control_base_classes(),
      form_control_state_classes(),
      "text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 h-9 w-full min-w-0 rounded-md bg-transparent px-3 py-1 text-base md:text-sm"
    ]
  end

  defp form_control_base_classes do
    "border-input border shadow-xs transition-[color,box-shadow] outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50"
  end

  defp form_control_state_classes do
    [
      "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
      "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive"
    ]
  end

  # -- FormField helpers -------------------------------------------------------

  defp unwrap_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    raw_errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
    translated = Enum.map(raw_errors, &translate_error/1)

    assigns
    |> assign(:field, nil)
    |> then(fn a -> if is_nil(a[:id]), do: assign(a, :id, field.id), else: a end)
    |> then(fn a -> if is_nil(a[:name]), do: assign(a, :name, field.name), else: a end)
    |> then(fn a -> if is_nil(a[:value]), do: assign(a, :value, field.value), else: a end)
    |> maybe_put_errors(translated)
  end

  defp unwrap_field(assigns), do: assigns

  defp maybe_put_errors(%{errors: errors} = assigns, _auto_errors) when not is_nil(errors),
    do: assigns

  defp maybe_put_errors(assigns, errors), do: assign(assigns, :errors, errors)

  defp direct_label_slot?(slot) do
    not is_nil(slot[:for]) or not is_nil(slot[:class])
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp selected_option(options, value) when is_list(options) and is_binary(value) do
    Enum.find(options, &(&1.value == value))
  end

  defp selected_option(_options, _value), do: nil

  defp input_otp_separator_indexes(groups, length) do
    groups
    |> Enum.map_reduce(0, fn group_size, offset ->
      next_offset = offset + group_size
      {next_offset - 1, next_offset}
    end)
    |> elem(0)
    |> Enum.filter(&(&1 >= 0 and &1 < length - 1))
  end
end
