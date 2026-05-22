defmodule CinderUI.Components.Forms.Controls do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]
  import CinderUI.Components.Forms.Field, only: [field_error: 1, label: 1]
  import CinderUI.Components.Forms.Helpers

  alias CinderUI.Icons
  alias Phoenix.HTML.Form

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
    field_value = if had_field, do: assigns.field.value

    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a ->
        if had_field do
          assign(a, :checked, Form.normalize_value("checkbox", field_value))
        else
          a
        end
      end)
      |> then(fn a -> if is_nil(a[:errors]), do: assign(a, :errors, []), else: a end)
      |> assign(:classes, [
        "peer accent-primary border-input dark:bg-input/30 checked:bg-primary checked:text-primary-foreground checked:border-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive size-4 shrink-0 rounded-[4px] border shadow-xs transition-shadow outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
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
    field_value = if had_field, do: assigns.field.value

    assigns =
      assigns
      |> unwrap_field()
      |> then(fn a ->
        if had_field do
          assign(a, :checked, Form.normalize_value("checkbox", field_value))
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
            class="accent-primary border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50"
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
          class="accent-primary border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50"
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
  attr :value, :any, default: nil
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
      |> then(fn a -> if is_nil(a[:value]), do: assign(a, :value, 0), else: a end)
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
end
