defmodule CinderUI.Components.Forms do
  @moduledoc """
  Form-related components modeled after shadcn/ui.

  Included components:

  - `label/1`
  - `field/1`
  - `field_label/1`
  - `field_control/1`
  - `field_description/1`
  - `field_error/1`
  - `input/1`
  - `textarea/1`
  - `checkbox/1`
  - `switch/1`
  - `select/1`
  - `native_select/1`
  - `autocomplete/1`
  - `radio_group/1`
  - `slider/1`
  - `input_group/1`
  - `input_otp/1`
  """

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

  `field/1` remains the simplest composition helper. For more explicit form
  structure, compose it with `field_label/1`, `field_control/1`,
  `field_description/1`, and `field_error/1`.

  ## Examples

  ```heex title="Profile field" align="full"
  <.field>
    <:label><.label for="name">Name</.label></:label>
    <.input id="name" name="name" />
    <:description>Shown in your profile.</:description>
  </.field>
  ```

  ```heex title="Validation state" align="full"
  <.field>
    <:label><.label for="email">Work email</.label></:label>
    <.input id="email" name="email" type="email" />
    <:description>We'll send deployment alerts here.</:description>
    <:error>Please use your company domain.</:error>
  </.field>
  ```

  ```heex title="Explicit field composition" align="full"
  <.field invalid={true}>
    <:label>
      <.label for="workspace-slug">Workspace slug</.label>
    </:label>

    <.field_control>
      <.input id="workspace-slug" name="workspace[slug]" value="cinder-ui" />
    </.field_control>

    <.field_description>Used in your public workspace URL.</.field_description>
    <.field_error>Slug has already been taken.</.field_error>
  </.field>
  ```

  ```heex title="Phoenix validation flow" align="full"
  <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
    <.field invalid={@form[:owner].errors != []}>
      <:label>
        <.label for={@form[:owner].id}>Owner</.label>
      </:label>

      <.field_control>
        <.autocomplete
          id={@form[:owner].id}
          name={@form[:owner].name}
          value={@form[:owner].value}
          aria-label="Owner"
        >
          <:option value="levi" label="Levi Buzolic" description="Engineering" />
          <:option value="mira" label="Mira Chen" description="Design" />
          <:empty>No matching teammates.</:empty>
        </.autocomplete>
      </.field_control>

      <.field_description>Choose the teammate responsible for this workspace.</.field_description>
      <.field_error :for={{msg, _opts} <- @form[:owner].errors}>{msg}</.field_error>
    </.field>
  </.form>
  ```
  """)

  attr :class, :string, default: nil
  attr :invalid, :boolean, default: false
  slot :label
  slot :description
  slot :error
  slot :inner_block, required: true

  def field(assigns) do
    invalid = assigns.invalid || assigns.error != []

    assigns =
      assigns
      |> assign(:invalid, invalid)
      |> assign(:classes, ["group grid gap-2", assigns.class])

    ~H"""
    <div data-slot="field" data-invalid={@invalid} class={classes(@classes)}>
      <.field_label :if={@label != []}>{render_slot(@label)}</.field_label>
      <.field_control>{render_slot(@inner_block)}</.field_control>
      <.field_description :if={@description != []}>{render_slot(@description)}</.field_description>
      <.field_error :if={@error != []}>{render_slot(@error)}</.field_error>
    </div>
    """
  end

  doc("""
  Wraps field labels so shared spacing and invalid-state styling remain
  consistent across controls.
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def field_label(assigns) do
    assigns = assign(assigns, :classes, ["flex flex-col gap-1", assigns.class])

    ~H"""
    <div data-slot="field-label" class={classes(@classes)}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Wraps the main interactive control inside a field.
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def field_control(assigns) do
    assigns =
      assign(assigns, :classes, [
        "group-data-[invalid=true]:[&_[data-slot=input]]:border-destructive group-data-[invalid=true]:[&_[data-slot=input]]:ring-destructive/20 group-data-[invalid=true]:[&_[data-slot=textarea]]:border-destructive group-data-[invalid=true]:[&_[data-slot=textarea]]:ring-destructive/20 group-data-[invalid=true]:[&_[data-slot=select-trigger]]:border-destructive group-data-[invalid=true]:[&_[data-slot=autocomplete-input]]:border-destructive",
        assigns.class
      ])

    ~H"""
    <div data-slot="field-control" class={classes(@classes)}>{render_slot(@inner_block)}</div>
    """
  end

  doc("""
  Helper text shown beneath a field control.
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def field_description(assigns) do
    assigns =
      assign(assigns, :classes, ["text-muted-foreground text-sm", assigns.class])

    ~H"""
    <p data-slot="field-description" class={classes(@classes)}>{render_slot(@inner_block)}</p>
    """
  end

  doc("""
  Error or validation message shown beneath a field control.
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def field_error(assigns) do
    assigns =
      assign(assigns, :classes, ["text-destructive text-sm font-medium", assigns.class])

    ~H"""
    <p data-slot="field-error" class={classes(@classes)}>{render_slot(@inner_block)}</p>
    """
  end

  doc("""
  Renders an input with shadcn classes.

  ## Examples

      <.input id="email" type="email" placeholder="name@example.com" />

      <.input id="username" name="username" value="levi" />

      <.input id="avatar" name="avatar" type="file" accept="image/*" />
  """)

  attr :id, :string, default: nil
  attr :type, :string, default: "text"
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :class, :string, default: nil

  attr :rest, :global,
    include: ~w(accept autocomplete disabled maxlength minlength pattern readonly required step)

  def input(assigns) do
    assigns =
      assign(assigns, :classes, [
        "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        assigns.class
      ])

    ~H"""
    <input
      id={@id}
      type={@type}
      data-slot="input"
      name={@name}
      value={@value}
      placeholder={@placeholder}
      class={classes(@classes)}
      {@rest}
    />
    """
  end

  doc("""
  Renders a textarea with shadcn classes.

  ## Examples

      <.textarea id="bio" name="bio" rows={4} />

      <.textarea
        id="release_notes"
        name="release_notes"
        rows={8}
        placeholder="Summarize what changed in this release..."
      />

      <.textarea id="support_message" name="support_message" disabled value="Request submitted." />
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 4
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled maxlength minlength readonly required)

  def textarea(assigns) do
    assigns =
      assign(assigns, :classes, [
        "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        assigns.class
      ])

    ~H"""
    <textarea
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

      <.checkbox id="terms" name="terms">Accept terms</.checkbox>

      <.checkbox id="product_updates" name="product_updates" checked={true}>
        Notify me about product updates
      </.checkbox>
  """)

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def checkbox(assigns) do
    assigns =
      assign(assigns, :classes, [
        "peer border-input dark:bg-input/30 checked:bg-primary checked:text-primary-foreground checked:border-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive size-4 shrink-0 rounded-[4px] border shadow-xs transition-shadow outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        assigns.class
      ])

    ~H"""
    <label class="inline-flex items-center gap-2">
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
    </label>
    """
  end

  doc("""
  Renders a switch control with optional label content.

  ## Examples

      <.switch id="marketing" checked={@enabled}>Email updates</.switch>

      <.switch id="2fa" name="two_factor" checked={true} size={:sm}>
        Require two-factor authentication
      </.switch>

      <.switch id="notifications" disabled={true}>Push notifications</.switch>
  """)

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :size, :atom, default: :default, values: [:sm, :default]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def switch(assigns) do
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

    thumb_position =
      case assigns.size do
        :sm -> "peer-checked:translate-x-[calc(100%-2px)]"
        :default -> "peer-checked:translate-x-[calc(100%-2px)]"
      end

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:root_size, root_size)
      |> assign(:thumb_size, thumb_size)
      |> assign(:thumb_position, thumb_position)
      |> assign(:track_classes, [
        "peer appearance-none bg-input checked:bg-primary focus-visible:border-ring focus-visible:ring-ring/50 dark:bg-input/80 dark:checked:bg-primary inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        root_size,
        assigns.class
      ])

    ~H"""
    <label class="inline-flex items-center gap-2">
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

  ```heex title="Grouped labels" align="full"
  <.select id="assignee" name="assignee" placeholder="Assign a teammate">
    <:option value="levi" label="Levi" description="Engineering" />
    <:option value="mira" label="Mira" description="Design" />
  </.select>
  ```

  ```heex title="Disabled option" align="full"
  <.select id="region" name="region">
    <:option value="us" label="United States" />
    <:option value="eu" label="Europe" />
    <:option value="apac" label="APAC" disabled={true} />
  </.select>
  ```
  """)

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Choose an option"
  attr :disabled, :boolean, default: false
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

  def select(assigns) do
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
        !selected_option && "text-muted-foreground"
      ])
      |> assign(:content_classes, [
        "bg-popover text-popover-foreground absolute top-full left-0 z-50 mt-2 hidden max-h-72 w-full overflow-y-auto rounded-md border p-1 shadow-md outline-none",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        assigns.content_class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="select"
      data-state="closed"
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
        disabled={@disabled}
        class={classes(@trigger_classes)}
        {@rest}
      >
        <span data-slot="select-value" class="truncate">{@selected_label}</span>
        <span class="text-muted-foreground ml-2 shrink-0" aria-hidden="true">▾</span>
      </button>

      <div
        id={"#{@id}-content"}
        data-slot="select-content"
        data-select-content
        role="listbox"
        tabindex="-1"
        class={classes(@content_classes)}
      >
        <button
          :for={{option, index} <- Enum.with_index(@option)}
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
              "relative flex w-full items-start gap-2 rounded-sm px-2 py-1.5 text-left text-sm outline-hidden select-none",
              "hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground",
              "disabled:pointer-events-none disabled:opacity-50",
              @value == option.value && "bg-accent text-accent-foreground"
            ])
          }
        >
          <span class="min-w-0 flex-1">
            <span class="block truncate">{option.label}</span>
            <span :if={option[:description]} class="text-muted-foreground block text-xs">
              {option.description}
            </span>
          </span>
          <span :if={@value == option.value} class="shrink-0" aria-hidden="true">✓</span>
        </button>

        <div
          :if={@option == [] and @empty != []}
          data-slot="select-empty"
          class="text-muted-foreground px-2 py-1.5 text-sm"
        >
          {render_slot(@empty)}
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

      <.native_select name="timezone" value="utc">
        <:option value="utc" label="UTC" />
      </.native_select>

      <.native_select name="framework" value="phoenix">
        <:option value="phoenix" label="Phoenix" />
        <:option value="rails" label="Rails" />
        <:option value="laravel" label="Laravel" />
      </.native_select>

      <.native_select name="assignee" placeholder="Assign a teammate">
        <:option value="levi" label="Levi" />
        <:option value="sam" label="Sam" />
      </.native_select>
  """)

  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Choose an option"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def native_select(assigns) do
    assigns =
      assign(assigns, :classes, [
        "border-input placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 dark:hover:bg-input/50 focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:aria-invalid:border-destructive/50 h-8 w-full min-w-0 appearance-none rounded-lg border bg-transparent py-1 pr-8 pl-2.5 text-sm transition-colors outline-none select-none focus-visible:ring-3 disabled:pointer-events-none disabled:cursor-not-allowed aria-invalid:ring-3 data-[size=sm]:h-7 data-[size=sm]:rounded-[min(var(--radius-md),10px)] data-[size=sm]:py-0.5",
        assigns.class
      ])

    ~H"""
    <div
      data-slot="native-select-wrapper"
      class="group/native-select relative w-full has-[select:disabled]:opacity-50"
    >
      <select data-slot="native-select" name={@name} class={classes(@classes)} {@rest}>
        <option :if={is_nil(@value)} value="" disabled selected>{@placeholder}</option>
        <option :for={option <- @option} value={option.value} selected={@value == option.value}>
          {option.label}
        </option>
      </select>
      <CinderUI.Icons.icon
        name="chevron-down"
        class="text-muted-foreground pointer-events-none absolute top-1/2 right-2.5 size-4 -translate-y-1/2 select-none"
        aria-hidden="true"
      />
    </div>
    """
  end

  doc("""
  Renders a filterable autocomplete input backed by a hidden form value.

  This is intended for searching and selecting from a known set of options. Use
  `select/1` when you want a trigger-driven listbox instead of a text input.

  ## Examples

  ```heex title="Autocomplete" align="full"
  <.autocomplete id="team-owner" name="owner" value="levi">
    <:option value="levi" label="Levi Buzolic" description="Engineering" />
    <:option value="mira" label="Mira Chen" description="Design" />
    <:option value="sam" label="Sam Hall" description="Operations" />
  </.autocomplete>
  ```

  ```heex title="Loading state" align="full"
  <.autocomplete id="repo-search" name="repo" loading={true}>
    <:option value="cinder" label="cinder_ui" />
  </.autocomplete>
  ```
  """)

  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Search options..."
  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
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
    <div
      id={@id}
      data-slot="autocomplete"
      data-state="closed"
      data-selected-label={@selected_label}
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
        aria-autocomplete="list"
        aria-controls={"#{@id}-content"}
        aria-expanded="false"
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
          Loading...
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
              "relative flex w-full items-start gap-2 rounded-sm px-2 py-1.5 text-left text-sm outline-hidden select-none",
              "hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground",
              "disabled:pointer-events-none disabled:opacity-50",
              @value == option.value && "bg-accent text-accent-foreground"
            ])
          }
        >
          <span class="min-w-0 flex-1">
            <span class="block truncate">{option.label}</span>
            <span :if={option[:description]} class="text-muted-foreground block text-xs">
              {option.description}
            </span>
          </span>
          <span :if={@value == option.value} class="shrink-0" aria-hidden="true">✓</span>
        </button>

        <div
          :if={@empty != []}
          data-slot="autocomplete-empty"
          class="text-muted-foreground hidden px-2 py-1.5 text-sm"
        >
          {render_slot(@empty)}
        </div>
      </div>
    </div>
    """
  end

  doc("""
  Renders a radio group with native radio inputs.

  ## Examples

      <.radio_group name="plan" value="pro">
        <:option value="free" label="Free" />
        <:option value="pro" label="Pro" />
      </.radio_group>

      <.radio_group name="billing_cycle" value="yearly">
        <:option value="monthly" label="Monthly billing" />
        <:option value="yearly" label="Yearly billing (save 20%)" />
      </.radio_group>
  """)

  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def radio_group(assigns) do
    assigns = assign(assigns, :classes, ["grid gap-3", assigns.class])

    ~H"""
    <div data-slot="radio-group" role="radiogroup" class={classes(@classes)}>
      <label :for={option <- @option} class="inline-flex items-center gap-2 text-sm">
        <input
          data-slot="radio-group-item"
          type="radio"
          name={@name}
          value={option.value}
          checked={@value == option.value}
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

      <.slider id="volume" name="volume" value={45} min={0} max={100} step={1} />

      <.slider id="cpu_limit" name="cpu_limit" value={2} min={1} max={8} step={1} />
  """)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :integer, default: 0
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :class, :string, default: nil
  attr :rest, :global

  def slider(assigns) do
    assigns =
      assign(assigns, :classes, [
        "accent-primary h-2 w-full cursor-pointer appearance-none rounded-full bg-primary/20",
        assigns.class
      ])

    ~H"""
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
    """
  end

  doc("""
  Wraps an input and sibling controls (buttons/icons) in a single inline group.

  ## Examples

  ```heex title="Search with action" align="full"
  <.input_group>
    <.input placeholder="Search" />
    <.button variant={:ghost} size={:xs}>Go</.button>
  </.input_group>
  ```

  ```heex title="Handle input" align="full"
  <.input_group>
    <span class="text-muted-foreground inline-flex items-center px-3 text-sm">@</span>
    <.input placeholder="organization" />
  </.input_group>
  ```

  ```heex title="Copy URL action" align="full"
  <.input_group>
    <.input placeholder="https://example.com" />
    <.button variant={:outline} size={:sm}>Copy</.button>
  </.input_group>
  ```
  """)

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def input_group(assigns) do
    assigns =
      assign(assigns, :classes, [
        "dark:bg-input/30 relative flex h-9 w-full min-w-0 items-stretch rounded-md border border-input bg-transparent shadow-xs transition-[color,box-shadow]",
        "has-[:focus-visible]:border-ring has-[:focus-visible]:ring-ring/50 has-[:focus-visible]:ring-[3px]",
        "[&>*]:relative [&>*]:h-full [&>*]:focus-visible:z-10",
        "[&>*:first-child]:rounded-l-md [&>*:last-child]:rounded-r-md",
        "[&>*:not(:last-child)]:border-r [&>*:not(:last-child)]:border-input",
        "[&>[data-slot=input]]:h-full [&>[data-slot=input]]:rounded-none [&>[data-slot=input]]:border-0 [&>[data-slot=input]]:bg-transparent [&>[data-slot=input]]:shadow-none [&>[data-slot=input]]:focus-visible:ring-0",
        "[&>[data-slot=button]]:h-6 [&>[data-slot=button]]:self-center [&>[data-slot=button]]:rounded-[calc(var(--radius)-5px)] [&>[data-slot=button]]:border-0 [&>[data-slot=button]]:px-2 [&>[data-slot=button]]:text-sm [&>[data-slot=button]]:shadow-none [&>[data-slot=button]]:focus-visible:ring-0",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-group" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Renders an OTP-style segmented input layout.

  This component renders one input per position and can be wired using standard
  Phoenix input names such as `code[]`.

  ## Examples

      <.input_otp name="verification_code[]" length={6} />

      <.input_otp
        name="recovery_code[]"
        length={8}
        values={["1", "2", "3", "", "", "", "", ""]}
      />
  """)

  attr :name, :string, default: "code[]"
  attr :length, :integer, default: 6
  attr :values, :list, default: []
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil
  attr :rest, :global

  def input_otp(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex items-center gap-2",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-otp" class={classes(@classes)}>
      <input
        :for={index <- Enum.to_list(0..(@length - 1))}
        type="text"
        inputmode="numeric"
        pattern="[0-9]*"
        maxlength="1"
        name={@name}
        value={Enum.at(@values, index, "")}
        class={
          classes([
            "border-input focus-visible:border-ring focus-visible:ring-ring/50 h-10 w-10 rounded-md border bg-transparent text-center text-sm shadow-xs outline-none focus-visible:ring-[3px]",
            @input_class
          ])
        }
        {@rest}
      />
    </div>
    """
  end

  defp selected_option(options, value) when is_list(options) and is_binary(value) do
    Enum.find(options, &(&1.value == value))
  end

  defp selected_option(_options, _value), do: nil
end
