defmodule CinderUI.Components.FormsTest.AutocompleteProbe do
  use Phoenix.Component

  import CinderUI.Components.Forms, only: [autocomplete: 1]

  def render(assigns) do
    ~H"""
    <.autocomplete id="framework-search" name="framework" open={true}>
      <:option value="next" label="Next.js">
        <span data-slot="probe-custom-framework">
          <strong>Next.js</strong>
          <span>React framework</span>
        </span>
      </:option>
    </.autocomplete>
    """
  end
end

defmodule CinderUI.Components.FormsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Forms
  alias CinderUI.Components.FormsTest.AutocompleteProbe
  alias CinderUI.TestHelpers
  alias Phoenix.HTML

  describe "input with FormField" do
    test "extracts id, name, value from field" do
      form = Phoenix.Component.to_form(%{"name" => "Alice"}, as: :user)

      html =
        render_component(&Forms.input/1, %{
          field: form[:name]
        })

      assert TestHelpers.attr(html, "[data-slot='input']", "id") == "user_name"
      assert TestHelpers.attr(html, "[data-slot='input']", "name") == "user[name]"
      assert TestHelpers.attr(html, "[data-slot='input']", "value") == "Alice"
    end

    test "renders label when label attr is provided" do
      form = Phoenix.Component.to_form(%{"name" => ""}, as: :user)

      html =
        render_component(&Forms.input/1, %{
          field: form[:name],
          label: "Full Name"
        })

      assert TestHelpers.text(html, "[data-slot='label']") == "Full Name"
      assert TestHelpers.attr(html, "[data-slot='label']", "for") == "user_name"
    end

    test "renders errors from explicit errors attr" do
      html =
        render_component(&Forms.input/1, %{
          id: "name",
          name: "name",
          errors: ["can't be blank"]
        })

      assert TestHelpers.text(html, "[data-slot='field-error']") == "can't be blank"
    end

    test "explicit id overrides field id" do
      form = Phoenix.Component.to_form(%{"name" => ""}, as: :user)

      html =
        render_component(&Forms.input/1, %{
          field: form[:name],
          id: "custom-id"
        })

      assert TestHelpers.attr(html, "[data-slot='input']", "id") == "custom-id"
    end

    test "renders bare input when no label or errors" do
      form = Phoenix.Component.to_form(%{"name" => ""}, as: :user)

      html =
        render_component(&Forms.input/1, %{
          field: form[:name]
        })

      refute html =~ "data-slot=\"label\""
      refute html =~ "data-slot=\"field-error\""
    end

    test "translates error tuples from field errors" do
      html =
        render_component(&Forms.input/1, %{
          id: "count",
          name: "count",
          errors: ["must be at least 3"]
        })

      assert TestHelpers.text(html, "[data-slot='field-error']") == "must be at least 3"
    end
  end

  describe "textarea with FormField" do
    test "extracts id, name, value from field" do
      form = Phoenix.Component.to_form(%{"notes" => "hello"}, as: :item)
      html = render_component(&Forms.textarea/1, %{field: form[:notes]})
      assert TestHelpers.attr(html, "[data-slot='textarea']", "id") == "item_notes"
      assert TestHelpers.attr(html, "[data-slot='textarea']", "name") == "item[notes]"
      assert html =~ "hello"
    end

    test "renders label and errors" do
      html =
        render_component(&Forms.textarea/1, %{
          id: "notes",
          name: "notes",
          label: "Notes",
          errors: ["too short"]
        })

      assert TestHelpers.text(html, "[data-slot='label']") == "Notes"
      assert TestHelpers.text(html, "[data-slot='field-error']") == "too short"
    end
  end

  test "input renders with data-slot and forwards min/max attributes" do
    html =
      render_component(&Forms.input/1, %{
        id: "capacity",
        type: "number",
        min: "1",
        max: "10"
      })

    assert TestHelpers.attr(html, "[data-slot='input']", "type") == "number"
    assert TestHelpers.attr(html, "[data-slot='input']", "min") == "1"
    assert TestHelpers.attr(html, "[data-slot='input']", "max") == "10"
  end

  describe "number_field with FormField" do
    test "extracts id, name, value from field" do
      form = Phoenix.Component.to_form(%{"quantity" => "5"}, as: :order)
      html = render_component(&Forms.number_field/1, %{field: form[:quantity]})

      assert TestHelpers.attr(html, "[data-slot='number-field-input']", "name") ==
               "order[quantity]"

      assert TestHelpers.attr(html, "[data-slot='number-field-input']", "value") == "5"
    end

    test "renders label and errors" do
      form = Phoenix.Component.to_form(%{"qty" => ""}, as: :order)

      html =
        render_component(&Forms.number_field/1, %{
          field: form[:qty],
          label: "Quantity",
          errors: ["must be positive"]
        })

      assert TestHelpers.text(html, "[data-slot='label']") == "Quantity"
      assert TestHelpers.text(html, "[data-slot='field-error']") == "must be positive"
    end
  end

  test "number_field renders buttons and forwards numeric constraints" do
    html =
      render_component(&Forms.number_field/1, %{
        id: "seat-count",
        name: "seats",
        value: 3,
        min: 1,
        max: 10,
        step: 0.5
      })

    assert TestHelpers.attr(html, "[data-slot='number-field']", "data-slot") == "number-field"
    assert TestHelpers.attr(html, "[data-slot='number-field-input']", "type") == "number"
    assert TestHelpers.attr(html, "[data-slot='number-field-input']", "min") == "1"
    assert TestHelpers.attr(html, "[data-slot='number-field-input']", "max") == "10"
    assert TestHelpers.attr(html, "[data-slot='number-field-input']", "step") == "0.5"

    assert TestHelpers.attr(html, "[data-slot='number-field-decrement']", "aria-label") ==
             "Decrease value"

    assert TestHelpers.attr(html, "[data-slot='number-field-increment']", "aria-label") ==
             "Increase value"

    assert TestHelpers.attr(html, "[data-slot='number-field-decrement']", "onclick") =~
             "stepDown()"

    assert TestHelpers.attr(html, "[data-slot='number-field-increment']", "onclick") =~ "stepUp()"
  end

  describe "select with FormField" do
    test "extracts name and value from field" do
      form = Phoenix.Component.to_form(%{"role" => "admin"}, as: :user)

      html =
        render_component(&Forms.select/1, %{
          field: form[:role],
          option: [
            %{value: "user", label: "User", inner_block: fn -> "" end},
            %{value: "admin", label: "Admin", inner_block: fn -> "" end}
          ]
        })

      assert TestHelpers.attr(html, "[data-slot='select-input']", "name") == "user[role]"
      assert TestHelpers.attr(html, "[data-slot='select-input']", "value") == "admin"
    end
  end

  test "select renders custom trigger, hidden input, and items" do
    html =
      render_component(&Forms.select/1, %{
        id: "role",
        name: "role",
        value: "admin",
        option: [
          %{value: "user", label: "User", inner_block: fn -> "" end},
          %{value: "admin", label: "Admin", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='select']", "phx-hook") == "CuiSelect"
    assert TestHelpers.attr(html, "[data-slot='select-trigger']", "type") == "button"
    assert TestHelpers.attr(html, "[data-slot='select-input']", "name") == "role"
    assert TestHelpers.attr(html, "[data-slot='select-input']", "value") == "admin"
    assert TestHelpers.find_all(html, "[data-select-item]") |> length() == 2
    assert TestHelpers.text(html, "[data-slot='select-value']") == "Admin"
    refute TestHelpers.has_class?(html, "[data-slot='select-group']", "py-1")
  end

  test "select supports grouped options, clear button, and default empty state" do
    html =
      render_component(&Forms.select/1, %{
        id: "owner",
        name: "owner",
        value: "mira",
        clearable: true,
        option: [
          %{value: "levi", label: "Levi", group: "Engineering", inner_block: fn -> "" end},
          %{value: "mira", label: "Mira", group: "Design", inner_block: fn -> "" end}
        ]
      })

    empty_html =
      render_component(&Forms.select/1, %{
        id: "empty-select",
        option: [],
        empty: []
      })

    assert TestHelpers.find_all(html, "[data-slot='select-group']") |> length() == 2
    assert TestHelpers.has_class?(html, "[data-slot='select-group']", "py-1")

    assert TestHelpers.find_all(html, "[data-slot='select-group-label']")
           |> Enum.map(fn node -> node |> Floki.text() |> String.trim() end) == [
             "Engineering",
             "Design"
           ]

    assert TestHelpers.attr(html, "[data-slot='select-trigger']", "aria-activedescendant") == ""
    assert TestHelpers.find_all(html, "[data-slot='select-clear']") |> length() == 1
    assert TestHelpers.text(empty_html, "[data-slot='select-empty']") == "No options available."
  end

  describe "native_select with FormField" do
    test "extracts id, name, value from field and renders options from options attr" do
      form = Phoenix.Component.to_form(%{"role" => "admin"}, as: :user)

      html =
        render_component(&Forms.native_select/1, %{
          field: form[:role],
          options: [{"User", "user"}, {"Admin", "admin"}]
        })

      assert TestHelpers.attr(html, "[data-slot='native-select']", "id") == "user_role"
      assert TestHelpers.attr(html, "[data-slot='native-select']", "name") == "user[role]"
      assert TestHelpers.find_all(html, "option") |> length() == 2
    end

    test "renders label and errors" do
      html =
        render_component(&Forms.native_select/1, %{
          id: "role",
          name: "role",
          label: "Role",
          errors: ["is invalid"],
          options: [{"User", "user"}]
        })

      assert TestHelpers.text(html, "[data-slot='label']") == "Role"
      assert TestHelpers.text(html, "[data-slot='field-error']") == "is invalid"
    end

    test "option slots take precedence over options attr" do
      html =
        render_component(&Forms.native_select/1, %{
          id: "role",
          name: "role",
          value: "admin",
          options: [{"Ignored", "ignored"}],
          option: [%{value: "admin", label: "Admin", inner_block: fn -> "" end}]
        })

      assert TestHelpers.find_all(html, "option") |> length() == 1
      refute html =~ "Ignored"
    end
  end

  test "native_select renders native wrapper and element" do
    html =
      render_component(&Forms.native_select/1, %{
        name: "role",
        value: "admin",
        option: [
          %{value: "user", label: "User", inner_block: fn -> "" end},
          %{value: "admin", label: "Admin", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='native-select-wrapper']", "data-slot") ==
             "native-select-wrapper"

    assert TestHelpers.attr(html, "[data-slot='native-select'] option[selected]", "value") ==
             "admin"

    assert TestHelpers.has_class?(html, "[data-slot='native-select']", "pr-8")
    assert TestHelpers.has_class?(html, "[data-slot='native-select']", "h-9")
    assert TestHelpers.has_class?(html, "[data-slot='native-select']", "rounded-md")
    assert TestHelpers.has_class?(html, "svg", "right-3")
  end

  describe "autocomplete with FormField" do
    test "extracts name and value from field" do
      form = Phoenix.Component.to_form(%{"owner" => "levi"}, as: :project)

      html =
        render_component(&Forms.autocomplete/1, %{
          field: form[:owner],
          option: [%{value: "levi", label: "Levi", inner_block: fn -> "" end}]
        })

      assert TestHelpers.attr(html, "[data-slot='autocomplete-value']", "name") ==
               "project[owner]"
    end
  end

  test "autocomplete renders visible and hidden inputs plus options" do
    html =
      render_component(&Forms.autocomplete/1, %{
        id: "owner",
        name: "owner",
        value: "levi",
        option: [
          %{
            value: "levi",
            label: "Levi Buzolic",
            description: "Engineering",
            inner_block: fn -> "" end
          },
          %{value: "mira", label: "Mira Chen", description: "Design", inner_block: fn -> "" end}
        ],
        empty: [%{inner_block: fn _, _ -> "No match" end}]
      })

    assert TestHelpers.attr(html, "[data-slot='autocomplete']", "phx-hook") == "CuiAutocomplete"
    assert TestHelpers.attr(html, "[data-slot='autocomplete-input']", "role") == "combobox"
    assert TestHelpers.attr(html, "[data-slot='autocomplete-value']", "value") == "levi"
    assert TestHelpers.find_all(html, "[data-slot='autocomplete-item']") |> length() == 2
    assert TestHelpers.text(html, "[data-slot='autocomplete-empty']") == "No match"
  end

  test "autocomplete popup renders trigger and search input inside content" do
    html =
      render_component(&Forms.autocomplete/1, %{
        id: "country",
        name: "country",
        value: "au",
        variant: :popup,
        open: true,
        placeholder: "Search countries...",
        option: [
          %{value: "au", label: "Australia", inner_block: fn -> "" end},
          %{value: "nz", label: "New Zealand", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='autocomplete']", "data-variant") == "popup"
    assert TestHelpers.attr(html, "[data-slot='autocomplete']", "data-state") == "open"

    assert TestHelpers.attr(html, "[data-slot='autocomplete-trigger']", "aria-haspopup") ==
             "listbox"

    assert TestHelpers.text(html, "[data-slot='autocomplete-trigger-value']") == "Australia"
    assert TestHelpers.attr(html, "[data-slot='autocomplete-value']", "value") == "au"
    assert TestHelpers.has_class?(html, "[data-slot='autocomplete-content']", "block")
    refute TestHelpers.has_class?(html, "[data-slot='autocomplete-content']", "hidden")

    assert TestHelpers.find_all(
             html,
             "[data-slot='autocomplete-content'] [data-slot='autocomplete-input']"
           )
           |> length() == 1
  end

  test "autocomplete supports grouped and custom option content" do
    html =
      render_component(&Forms.autocomplete/1, %{
        id: "framework-search",
        name: "framework",
        option: [
          %{
            value: "next",
            label: "Next.js",
            group: "Frontend",
            inner_block: fn _, _ ->
              HTML.raw("""
              <span data-slot="custom-framework">
                <strong>Next.js</strong>
                <span>React framework</span>
              </span>
              """)
            end
          },
          %{
            value: "phoenix",
            label: "Phoenix",
            group: "Backend",
            description: "Elixir framework",
            inner_block: fn -> "" end
          }
        ]
      })

    assert TestHelpers.find_all(html, "[data-slot='autocomplete-group']") |> length() == 2
    assert TestHelpers.has_class?(html, "[data-slot='autocomplete-group']", "py-1")
    assert TestHelpers.text(html, "[data-slot='autocomplete-group-label']") == "Frontend"
    assert TestHelpers.text(html, "[data-slot='custom-framework']") == "Next.js React framework"

    assert TestHelpers.attr(
             html,
             "[data-slot='autocomplete-item'][data-value='next']",
             "data-label"
           ) == "Next.js"

    assert TestHelpers.text(html, "[data-slot='autocomplete-item'][data-value='phoenix']") =~
             "Elixir framework"
  end

  test "autocomplete renders custom option bodies from HEEx slots" do
    html = render_component(&AutocompleteProbe.render/1, %{})

    assert TestHelpers.text(html, "[data-slot='probe-custom-framework']") ==
             "Next.js React framework"

    refute TestHelpers.has_class?(html, "[data-slot='autocomplete-group']", "py-1")
  end

  test "autocomplete renders loading text and server-search-friendly markup" do
    html =
      render_component(&Forms.autocomplete/1, %{
        id: "repo-search",
        name: "repo",
        loading: true,
        loading_text: "Searching repositories...",
        option: [],
        empty: [%{inner_block: fn _, _ -> "No repositories found" end}]
      })

    assert TestHelpers.attr(html, "[data-slot='autocomplete']", "data-loading") == "data-loading"

    assert TestHelpers.text(html, "[data-slot='autocomplete-loading']") ==
             "Searching repositories..."

    assert TestHelpers.find_all(html, "[data-slot='autocomplete-empty']") |> length() == 1
  end

  test "autocomplete renders a default empty message when none is provided" do
    html =
      render_component(&Forms.autocomplete/1, %{
        id: "empty-autocomplete",
        option: []
      })

    assert TestHelpers.text(html, "[data-slot='autocomplete-empty']") == "No results found."

    assert TestHelpers.attr(html, "[data-slot='autocomplete-input']", "aria-activedescendant") ==
             ""
  end

  test "field infers invalid state from error slot and renders subcomponents" do
    html =
      render_component(&Forms.field/1, %{
        label: [%{inner_block: fn _, _ -> "Username" end}],
        description: [%{inner_block: fn _, _ -> "Public handle" end}],
        message: [%{inner_block: fn _, _ -> "Saved automatically" end}],
        error: [%{inner_block: fn _, _ -> "Already taken" end}],
        inner_block: [%{inner_block: fn _, _ -> HTML.raw("<input data-slot=\"input\" />") end}]
      })

    assert TestHelpers.attr(html, "[data-slot='field']", "data-invalid") == "data-invalid"
    assert TestHelpers.text(html, "[data-slot='field-label']") == "Username"
    assert TestHelpers.text(html, "[data-slot='field-description']") == "Public handle"
    assert TestHelpers.text(html, "[data-slot='field-message']") == "Saved automatically"
    assert TestHelpers.text(html, "[data-slot='field-error']") == "Already taken"

    assert TestHelpers.find_all(html, "[data-slot='field-control'] [data-slot='input']")
           |> length() == 1
  end

  test "field auto-renders label when label slot attrs are provided" do
    html =
      render_component(&Forms.field/1, %{
        label: TestHelpers.slot("Username", %{for: "account_username", class: "tracking-tight"}),
        inner_block: [%{inner_block: fn _, _ -> HTML.raw("<input data-slot=\"input\" />") end}]
      })

    assert TestHelpers.text(html, "[data-slot='field-label'] [data-slot='label']") == "Username"

    assert TestHelpers.attr(html, "[data-slot='field-label'] [data-slot='label']", "for") ==
             "account_username"

    assert TestHelpers.has_class?(
             html,
             "[data-slot='field-label'] [data-slot='label']",
             "tracking-tight"
           )
  end

  test "field preserves custom label markup without wrapping it again" do
    html =
      render_component(&Forms.field/1, %{
        label: [
          %{
            inner_block: fn _, _ ->
              HTML.raw("""
              <label data-slot="label" for="account_username">Username</label>
              <span data-slot="label-note">Shown publicly</span>
              """)
            end
          }
        ],
        inner_block: [%{inner_block: fn _, _ -> HTML.raw("<input data-slot=\"input\" />") end}]
      })

    assert TestHelpers.text(html, "[data-slot='field-label']") == "Username Shown publicly"

    assert TestHelpers.find_all(html, "[data-slot='field-label'] [data-slot='label']")
           |> length() == 1
  end

  test "field_control carries invalid-state selectors for shared controls" do
    html =
      render_component(&Forms.field_control/1, %{
        inner_block: [%{inner_block: fn _, _ -> "stub" end}]
      })

    assert TestHelpers.attr(html, "[data-slot='field-control']", "data-slot") == "field-control"
    class_attr = TestHelpers.attr(html, "[data-slot='field-control']", "class")
    assert class_attr =~ "data-slot=select-trigger"
    assert class_attr =~ "data-slot=number-field-input"
    assert class_attr =~ "data-slot=native-select"
    assert class_attr =~ "data-slot=autocomplete-input"
    assert class_attr =~ "data-slot=combobox-input"
    assert class_attr =~ "data-slot=switch"
    assert class_attr =~ "data-slot=checkbox"
    assert class_attr =~ "data-slot=radio-group-item"
  end

  test "label and field helper components render structural classes" do
    label_html =
      render_component(&Forms.label/1, %{
        for: "email",
        inner_block: CinderUI.TestHelpers.slot("Email")
      })

    field_label_html =
      render_component(&Forms.field_label/1, %{
        inner_block: CinderUI.TestHelpers.slot("Field label")
      })

    description_html =
      render_component(&Forms.field_description/1, %{
        inner_block: CinderUI.TestHelpers.slot("Helpful text")
      })

    message_html =
      render_component(&Forms.field_message/1, %{
        inner_block: CinderUI.TestHelpers.slot("Saved")
      })

    assert TestHelpers.attr(label_html, "[data-slot='label']", "for") == "email"
    assert TestHelpers.text(field_label_html, "[data-slot='field-label']") == "Field label"

    assert TestHelpers.has_class?(
             description_html,
             "[data-slot='field-description']",
             "text-muted-foreground"
           )

    assert TestHelpers.text(description_html, "[data-slot='field-description']") == "Helpful text"
    assert TestHelpers.has_class?(message_html, "[data-slot='field-message']", "text-foreground")
    assert TestHelpers.text(message_html, "[data-slot='field-message']") == "Saved"
  end

  describe "checkbox with FormField" do
    test "extracts checked state from field value" do
      form = Phoenix.Component.to_form(%{"online" => true}, as: :store)
      html = render_component(&Forms.checkbox/1, %{field: form[:online]})
      assert TestHelpers.attr(html, "[data-slot='checkbox']", "id") == "store_online"
      assert TestHelpers.attr(html, "[data-slot='checkbox']", "name") == "store[online]"
      assert TestHelpers.attr(html, "[data-slot='checkbox']", "checked") == "checked"
    end

    test "renders unchecked when field value is false" do
      form = Phoenix.Component.to_form(%{"online" => false}, as: :store)
      html = render_component(&Forms.checkbox/1, %{field: form[:online]})
      refute TestHelpers.attr(html, "[data-slot='checkbox']", "checked")
      assert TestHelpers.attr(html, "[data-slot='checkbox']", "value") == "true"
    end

    test "explicit input value does not force checked when field value is false" do
      form = Phoenix.Component.to_form(%{"online" => false}, as: :store)
      html = render_component(&Forms.checkbox/1, %{field: form[:online], value: "yes"})
      refute TestHelpers.attr(html, "[data-slot='checkbox']", "checked")
      assert TestHelpers.attr(html, "[data-slot='checkbox']", "value") == "yes"
    end

    test "renders hidden input for unchecked submission" do
      form = Phoenix.Component.to_form(%{"active" => false}, as: :item)
      html = render_component(&Forms.checkbox/1, %{field: form[:active]})
      assert TestHelpers.attr(html, "input[type='hidden']", "name") == "item[active]"
      assert TestHelpers.attr(html, "input[type='hidden']", "value") == "false"
    end

    test "renders label from label attr inline" do
      form = Phoenix.Component.to_form(%{"online" => false}, as: :store)
      html = render_component(&Forms.checkbox/1, %{field: form[:online], label: "Online"})
      assert html =~ "Online"
    end

    test "inner_block takes precedence over label attr" do
      html =
        render_component(&Forms.checkbox/1, %{
          id: "terms",
          name: "terms",
          label: "Fallback",
          inner_block: CinderUI.TestHelpers.slot("Accept Terms")
        })

      assert html =~ "Accept Terms"
      refute html =~ "Fallback"
    end
  end

  test "checkbox renders native input and label content" do
    html =
      render_component(&Forms.checkbox/1, %{
        id: "terms",
        checked: true,
        inner_block: CinderUI.TestHelpers.slot("Accept terms")
      })

    assert TestHelpers.attr(html, "[data-slot='checkbox']", "checked") == "checked"
    assert TestHelpers.has_class?(html, "[data-slot='checkbox']", "accent-primary")
    assert TestHelpers.text(html, "label") == "Accept terms"
  end

  describe "switch with FormField" do
    test "extracts checked state from field" do
      form = Phoenix.Component.to_form(%{"notifications" => true}, as: :prefs)
      html = render_component(&Forms.switch/1, %{field: form[:notifications]})
      assert TestHelpers.attr(html, "[data-slot='switch']", "data-state") == "checked"
      assert TestHelpers.attr(html, "[data-slot='switch']", "name") == "prefs[notifications]"
    end

    test "renders unchecked when field value is false" do
      form = Phoenix.Component.to_form(%{"notifications" => false}, as: :prefs)
      html = render_component(&Forms.switch/1, %{field: form[:notifications]})
      refute TestHelpers.attr(html, "[data-slot='switch']", "checked")
      assert TestHelpers.attr(html, "[data-slot='switch']", "data-state") == "unchecked"
      assert TestHelpers.attr(html, "[data-slot='switch']", "value") == "true"
    end

    test "explicit input value does not force checked when field value is false" do
      form = Phoenix.Component.to_form(%{"notifications" => false}, as: :prefs)
      html = render_component(&Forms.switch/1, %{field: form[:notifications], value: "yes"})
      refute TestHelpers.attr(html, "[data-slot='switch']", "checked")
      assert TestHelpers.attr(html, "[data-slot='switch']", "data-state") == "unchecked"
      assert TestHelpers.attr(html, "[data-slot='switch']", "value") == "yes"
    end

    test "renders label from label attr inline" do
      form = Phoenix.Component.to_form(%{"notify" => false}, as: :prefs)
      html = render_component(&Forms.switch/1, %{field: form[:notify], label: "Notifications"})
      assert html =~ "Notifications"
    end
  end

  test "switch hides native checkbox glyph and renders thumb" do
    html = render_component(&Forms.switch/1, %{id: "marketing", checked: true})

    assert TestHelpers.attr(html, "[data-slot='switch']", "data-slot") == "switch"
    assert TestHelpers.find_all(html, "[data-slot='switch-thumb']") |> length() == 1
    assert TestHelpers.has_class?(html, "[data-slot='switch']", "appearance-none")
    assert TestHelpers.has_class?(html, "[data-slot='switch']", "checked:bg-primary")

    assert TestHelpers.has_class?(
             html,
             "[data-slot='switch-thumb']",
             "peer-checked:translate-x-[calc(100%-2px)]"
           )
  end

  describe "slider with FormField" do
    test "extracts name and value from field" do
      form = Phoenix.Component.to_form(%{"volume" => "75"}, as: :settings)
      html = render_component(&Forms.slider/1, %{id: "volume", field: form[:volume]})
      assert TestHelpers.attr(html, "[data-slot='slider']", "name") == "settings[volume]"
      assert TestHelpers.attr(html, "[data-slot='slider']", "value") == "75"
    end
  end

  test "slider accepts fractional values" do
    html =
      render_component(&Forms.slider/1, %{
        id: "temperature",
        value: 0.5,
        min: 0.0,
        max: 1.0,
        step: 0.1
      })

    assert TestHelpers.attr(html, "[data-slot='slider']", "value") == "0.5"
    assert TestHelpers.attr(html, "[data-slot='slider']", "min") == "0.0"
    assert TestHelpers.attr(html, "[data-slot='slider']", "max") == "1.0"
    assert TestHelpers.attr(html, "[data-slot='slider']", "step") == "0.1"
  end

  describe "radio_group with FormField" do
    test "extracts name and value from field" do
      form = Phoenix.Component.to_form(%{"plan" => "pro"}, as: :account)

      html =
        render_component(&Forms.radio_group/1, %{
          field: form[:plan],
          option: [
            %{value: "free", label: "Free", inner_block: fn -> "" end},
            %{value: "pro", label: "Pro", inner_block: fn -> "" end}
          ]
        })

      inputs = TestHelpers.find_all(html, "input[type='radio']")
      assert length(inputs) == 2
    end

    test "renders fieldset with legend for label" do
      form = Phoenix.Component.to_form(%{"plan" => "free"}, as: :account)

      html =
        render_component(&Forms.radio_group/1, %{
          field: form[:plan],
          label: "Choose a plan",
          option: [%{value: "free", label: "Free", inner_block: fn -> "" end}]
        })

      assert html =~ "<fieldset"
      assert html =~ "<legend"
      assert html =~ "Choose a plan"
    end
  end

  test "radio_group supports disabled options" do
    html =
      render_component(&Forms.radio_group/1, %{
        name: "region",
        value: "us",
        option: [
          %{value: "us", label: "United States", inner_block: fn -> "" end},
          %{value: "eu", label: "Europe", disabled: true, inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='radio-group']", "data-slot") == "radio-group"
    assert TestHelpers.find_all(html, "[data-slot='radio-group-item']") |> length() == 2

    assert TestHelpers.has_class?(
             html,
             "[data-slot='radio-group-item'][value='us']",
             "accent-primary"
           )

    assert TestHelpers.attr(html, "[data-slot='radio-group-item'][value='eu']", "disabled") ==
             "disabled"

    disabled_label =
      html
      |> TestHelpers.find_all("label")
      |> Enum.find(fn node -> Floki.text(node) |> String.contains?("Europe") end)

    assert disabled_label

    assert disabled_label
           |> Floki.attribute("class")
           |> List.first()
           |> String.split()
           |> Enum.member?("opacity-50")
  end

  describe "input_otp with FormField" do
    test "extracts name from field and splits value into cells" do
      form = Phoenix.Component.to_form(%{"code" => "1234"}, as: :verify)
      html = render_component(&Forms.input_otp/1, %{field: form[:code], length: 4})
      inputs = TestHelpers.find_all(html, "[data-input-otp-input]")
      assert length(inputs) == 4
      assert inputs |> List.first() |> Floki.attribute("value") |> List.first() == "1"
    end
  end

  test "input_otp renders hook-enabled segmented inputs" do
    html =
      render_component(&Forms.input_otp/1, %{
        name: "verification_code[]",
        length: 4,
        values: ["1", "", "3", ""]
      })

    assert TestHelpers.attr(html, "[data-slot='input-otp']", "phx-hook") == "CuiInputOtp"
    assert TestHelpers.find_all(html, "[data-input-otp-input]") |> length() == 4
    assert TestHelpers.attr(html, "[data-input-otp-index='0']", "value") == "1"
    assert TestHelpers.attr(html, "[data-input-otp-index='2']", "value") == "3"
    assert TestHelpers.attr(html, "[data-slot='input-otp']", "id") =~ "cinder-ui-input-otp-"
  end

  test "input_otp supports grouped separators" do
    html =
      render_component(&Forms.input_otp/1, %{
        name: "backup_code[]",
        length: 6,
        groups: [3, 3]
      })

    assert TestHelpers.find_all(html, "[data-slot='input-otp-separator']") |> length() == 1

    assert TestHelpers.attr(
             html,
             "[data-slot='input-otp-separator']",
             "data-input-otp-separator-after"
           ) == "2"
  end

  test "input_otp renders no phantom cells for non-positive lengths" do
    for length <- [0, -1] do
      html = render_component(&Forms.input_otp/1, %{length: length})

      assert TestHelpers.find_all(html, "[data-input-otp-input]") == []
      assert TestHelpers.find_all(html, "[data-slot='input-otp-separator']") == []
    end
  end

  test "input_group renders unified styles for inline and block-end layouts" do
    html =
      render_component(&Forms.input_group/1, %{
        inner_block: [
          %{inner_block: fn _, _ -> "stub" end}
        ]
      })

    block_end_html =
      render_component(&Forms.input_group/1, %{
        align: :block_end,
        inner_block: [
          %{inner_block: fn _, _ -> "stub" end}
        ]
      })

    addon_html =
      render_component(&Forms.input_group_addon/1, %{
        inner_block: CinderUI.TestHelpers.slot("@")
      })

    block_end_addon_html =
      render_component(&Forms.input_group_addon/1, %{
        align: :block_end,
        inner_block: CinderUI.TestHelpers.slot("Footer")
      })

    assert TestHelpers.attr(html, "[data-slot='input-group']", "data-align") == "inline"

    assert TestHelpers.has_class?(
             html,
             "[data-slot='input-group']",
             "has-[:focus-visible]:ring-[3px]"
           )

    inline_class = TestHelpers.attr(html, "[data-slot='input-group']", "class")
    assert inline_class =~ "[data-slot=input-group-addon]]:inline-flex"
    assert inline_class =~ "[data-slot=input]]:border-0"
    refute inline_class =~ "overflow-hidden"
    assert inline_class =~ "[data-slot=autocomplete]]:flex-1"
    assert inline_class =~ "[data-slot=autocomplete]>[data-slot=autocomplete-input]]:border-0"
    assert inline_class =~ "[data-slot=autocomplete]>[data-slot=autocomplete-trigger]]:border-0"
    assert inline_class =~ "[data-slot=combobox]>[data-slot=combobox-input]]:border-0"
    assert inline_class =~ "[data-slot=textarea]]:border-0"
    assert inline_class =~ "[data-slot=select]_[data-slot=select-trigger]]:border-0"
    assert inline_class =~ "[data-slot=button]]:border-0"
    assert inline_class =~ "[data-slot=button]:last-child]:mr-1.5"
    assert inline_class =~ "[data-slot=input-group-addon]_[data-slot=button]]:h-6"

    assert TestHelpers.attr(block_end_html, "[data-slot='input-group']", "data-align") ==
             "block-end"

    assert TestHelpers.has_class?(block_end_html, "[data-slot='input-group']", "flex-col")

    assert TestHelpers.attr(block_end_html, "[data-slot='input-group']", "class") =~
             "[data-slot=input-group-addon][data-align=block-end]]:border-t"

    assert TestHelpers.attr(addon_html, "[data-slot='input-group-addon']", "data-slot") ==
             "input-group-addon"

    assert TestHelpers.has_class?(addon_html, "[data-slot='input-group-addon']", "inline-flex")

    assert TestHelpers.has_class?(
             addon_html,
             "[data-slot='input-group-addon']",
             "has-[>[data-slot=button]]:-mx-1.5"
           )

    assert TestHelpers.attr(block_end_addon_html, "[data-slot='input-group-addon']", "data-align") ==
             "block-end"
  end

  test "input_group_button renders compact non-submit button defaults" do
    html =
      render_component(&Forms.input_group_button/1, %{
        inner_block: TestHelpers.slot("Copy")
      })

    assert TestHelpers.attr(html, "[data-slot='button']", "type") == "button"
    assert TestHelpers.attr(html, "[data-slot='button']", "data-variant") == "ghost"
    assert TestHelpers.attr(html, "[data-slot='button']", "data-size") == "xs"
    assert TestHelpers.has_class?(html, "[data-slot='button']", "shadow-none")

    icon_html =
      render_component(&Forms.input_group_button/1, %{
        size: :icon_xs,
        "aria-label": "Copy",
        inner_block: TestHelpers.slot("C")
      })

    assert TestHelpers.attr(icon_html, "[data-slot='button']", "data-size") == "icon_xs"
    assert TestHelpers.attr(icon_html, "[data-slot='button']", "aria-label") == "Copy"
  end

  test "input_group_text renders styled addon text segment" do
    html =
      render_component(&Forms.input_group_text/1, %{
        inner_block: TestHelpers.slot("USD")
      })

    assert TestHelpers.attr(html, "[data-slot='input-group-text']", "data-slot") ==
             "input-group-text"

    assert TestHelpers.text(html, "[data-slot='input-group-text']") == "USD"
    assert TestHelpers.has_class?(html, "[data-slot='input-group-text']", "text-muted-foreground")
  end
end
