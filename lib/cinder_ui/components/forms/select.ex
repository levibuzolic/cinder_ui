defmodule CinderUI.Components.Forms.Select do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]
  import CinderUI.Components.Forms.Field, only: [field_error: 1, label: 1]
  import CinderUI.Components.Forms.Helpers

  alias CinderUI.Icons
  alias Phoenix.HTML.Safe

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
            data-disabled={if option[:disabled], do: "true", else: "false"}
            data-selected={if @value == option.value, do: "true", else: "false"}
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

  ```heex title="Autocomplete popup" align="full" vrt
  <div class="pb-48">
    <.autocomplete
      id="country-search"
      name="country"
      value="au"
      variant={:popup}
      placeholder="Search countries..."
      open={true}
    >
      <:option value="au" label="Australia" />
      <:option value="nz" label="New Zealand" />
      <:option value="us" label="United States" />
    </.autocomplete>
  </div>
  ```

  ```heex title="Grouped autocomplete" align="full" vrt
  <div class="pb-48">
    <.autocomplete
      id="timezone-search"
      name="timezone"
      placeholder="Search timezones..."
      open={true}
    >
      <:option value="nyc" label="(GMT-5) New York" group="Americas" />
      <:option value="lax" label="(GMT-8) Los Angeles" group="Americas" />
      <:option value="lon" label="(GMT+0) London" group="Europe" />
    </.autocomplete>
  </div>
  ```

  ```heex title="Custom autocomplete items" align="full" vrt
  <div class="pb-36">
    <.autocomplete
      id="framework-search"
      name="framework"
      open={true}
    >
      <:option value="next" label="Next.js">
        <span class="flex flex-col">
          <span class="font-medium">Next.js</span>
          <span class="text-muted-foreground text-xs">React framework</span>
        </span>
      </:option>
    </.autocomplete>
  </div>
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
  attr :variant, :atom, default: :input, values: [:input, :popup]
  attr :open, :boolean, default: false
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
    attr :group, :string
  end

  slot :trigger
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
        "bg-popover text-popover-foreground absolute top-full left-0 z-50 mt-2 max-h-72 w-full overflow-y-auto rounded-md border p-1 shadow-md outline-none",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        if(assigns.open, do: "block", else: "hidden"),
        assigns.content_class
      ])

    ~H"""
    <div :if={@label || @errors != []} class="space-y-2">
      <.label :if={@label} for={@id}>{@label}</.label>
      <.autocomplete_control
        id={@id}
        name={@name}
        value={@value}
        variant={@variant}
        open={@open}
        selected_label={@selected_label}
        placeholder={@placeholder}
        disabled={@disabled}
        loading={@loading}
        loading_text={@loading_text}
        option={@option}
        trigger={@trigger}
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
      variant={@variant}
      open={@open}
      selected_label={@selected_label}
      placeholder={@placeholder}
      disabled={@disabled}
      loading={@loading}
      loading_text={@loading_text}
      option={@option}
      trigger={@trigger}
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
  attr :variant, :atom, required: true
  attr :open, :boolean, required: true
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
  attr :trigger, :list, default: []
  attr :empty, :list, default: []

  defp autocomplete_control(assigns) do
    ~H"""
    <div
      id={@id}
      data-slot="autocomplete"
      data-state={if @open, do: "open", else: "closed"}
      data-variant={@variant}
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

      <button
        :if={@variant == :popup}
        type="button"
        data-slot="autocomplete-trigger"
        data-autocomplete-trigger
        aria-haspopup="listbox"
        aria-controls={"#{@id}-content"}
        aria-expanded={@open}
        disabled={@disabled}
        class={
          classes([
            "border-input bg-background text-foreground flex h-9 w-full items-center justify-between gap-2 rounded-md border px-3 py-2 text-sm shadow-xs outline-none transition-[color,box-shadow] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50",
            "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
          ])
        }
      >
        <span
          data-slot="autocomplete-trigger-value"
          data-custom-trigger={@trigger != []}
          class={classes(["truncate", @selected_label == "" && "text-muted-foreground"])}
        >
          <%= if @trigger != [] do %>
            {render_slot(@trigger, @selected_label)}
          <% else %>
            {if @selected_label == "", do: @placeholder, else: @selected_label}
          <% end %>
        </span>
        <Icons.icon name="chevron-down" class="size-4 opacity-50" aria-hidden="true" />
      </button>

      <input
        :if={@variant == :input}
        data-slot="autocomplete-input"
        data-autocomplete-input
        type="text"
        value={@selected_label}
        placeholder={@placeholder}
        autocomplete="off"
        role="combobox"
        aria-autocomplete="list"
        aria-controls={"#{@id}-content"}
        aria-expanded={@open}
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
        <input
          :if={@variant == :popup}
          data-slot="autocomplete-input"
          data-autocomplete-input
          type="text"
          value=""
          placeholder={@placeholder}
          autocomplete="off"
          role="combobox"
          aria-autocomplete="list"
          aria-controls={"#{@id}-content"}
          aria-expanded={@open}
          aria-activedescendant=""
          disabled={@disabled}
          class={
            classes([
              @input_classes,
              "mb-1 h-8 border-input/30 bg-input/30 shadow-none focus-visible:ring-0"
            ])
          }
          {@rest}
        />

        <div
          :if={@loading}
          data-slot="autocomplete-loading"
          class="text-muted-foreground px-2 py-1.5 text-sm"
        >
          {@loading_text}
        </div>

        <div
          :for={group <- grouped_options(@option)}
          :if={@option != []}
          data-slot="autocomplete-group"
          data-autocomplete-group
          class="py-1"
        >
          <div
            :if={group.label}
            data-slot="autocomplete-group-label"
            class="text-muted-foreground px-2 py-1 text-xs font-medium"
          >
            {group.label}
          </div>

          <button
            :for={{option, index} <- group.options}
            id={"#{@id}-autocomplete-option-#{index}"}
            type="button"
            role="option"
            data-slot="autocomplete-item"
            data-autocomplete-item
            data-value={option.value}
            data-label={option.label}
            data-disabled={if option[:disabled], do: "true", else: "false"}
            data-selected={if @value == option.value, do: "true", else: "false"}
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
            <%= if slot_has_content?(option) do %>
              {render_slot(option)}
            <% else %>
              <span class="min-w-0 flex-1">
                <span class="block truncate">{option.label}</span>
                <span :if={option[:description]} class="text-muted-foreground block text-xs">
                  {option.description}
                </span>
              </span>
            <% end %>
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

  defp slot_has_content?(%{inner_block: inner_block}) when is_function(inner_block, 2) do
    slot_content_present?(inner_block.(nil, nil))
  end

  defp slot_has_content?(%{inner_block: inner_block}) when is_function(inner_block, 1) do
    slot_content_present?(inner_block.(nil))
  end

  defp slot_has_content?(%{inner_block: inner_block}) when is_function(inner_block, 0) do
    slot_content_present?(inner_block.())
  end

  defp slot_has_content?(%{inner_block: inner_block}) do
    slot_content_present?(inner_block)
  end

  defp slot_has_content?(_slot), do: false

  defp slot_content_present?(content) do
    content
    |> slot_content_to_string()
    |> String.trim()
    |> then(&(&1 != ""))
  end

  defp slot_content_to_string(nil), do: ""

  defp slot_content_to_string(content) do
    content
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
