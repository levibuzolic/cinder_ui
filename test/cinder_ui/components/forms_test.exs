defmodule CinderUI.Components.FormsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Forms

  test "input renders with data-slot and forwards min/max attributes" do
    html =
      render_component(&Forms.input/1, %{
        id: "capacity",
        type: "number",
        min: "1",
        max: "10"
      })

    assert html =~ "data-slot=\"input\""
    assert html =~ "type=\"number\""
    assert html =~ "min=\"1\""
    assert html =~ "max=\"10\""
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

    assert html =~ "Admin"
    assert html =~ "data-slot=\"select\""
    assert html =~ "data-slot=\"select-trigger\""
    assert html =~ "data-slot=\"select-input\""
    assert html =~ "data-slot=\"select-item\""
    assert html =~ "phx-hook=\"CuiSelect\""
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

    assert html =~ "data-slot=\"select-group\""
    assert html =~ "data-slot=\"select-group-label\""
    assert html =~ "data-slot=\"select-clear\""
    assert html =~ "aria-activedescendant"
    assert empty_html =~ "No options available."
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

    assert html =~ "data-slot=\"native-select-wrapper\""
    assert html =~ "data-slot=\"native-select\""
    assert html =~ "pr-8"
    assert html =~ "right-2.5"
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

    assert html =~ "data-slot=\"autocomplete\""
    assert html =~ "data-slot=\"autocomplete-input\""
    assert html =~ "data-slot=\"autocomplete-value\""
    assert html =~ "data-slot=\"autocomplete-item\""
    assert html =~ "data-slot=\"autocomplete-empty\""
    assert html =~ ~s(role="combobox")
    assert html =~ "phx-hook=\"CuiAutocomplete\""
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

    assert html =~ "data-loading"
    assert html =~ "data-slot=\"autocomplete-loading\""
    assert html =~ "Searching repositories..."
    assert html =~ "data-slot=\"autocomplete-empty\""
  end

  test "autocomplete renders a default empty message when none is provided" do
    html =
      render_component(&Forms.autocomplete/1, %{
        id: "empty-autocomplete",
        option: []
      })

    assert html =~ "No results found."
    assert html =~ "aria-activedescendant"
  end

  test "field infers invalid state from error slot and renders subcomponents" do
    html =
      render_component(&Forms.field/1, %{
        label: [%{inner_block: fn _, _ -> "Username" end}],
        description: [%{inner_block: fn _, _ -> "Public handle" end}],
        message: [%{inner_block: fn _, _ -> "Saved automatically" end}],
        error: [%{inner_block: fn _, _ -> "Already taken" end}],
        inner_block: [%{inner_block: fn _, _ -> "<input data-slot=\"input\" />" end}]
      })

    assert html =~ "data-slot=\"field\""
    assert html =~ "data-invalid"
    assert html =~ "data-slot=\"field-label\""
    assert html =~ "data-slot=\"field-control\""
    assert html =~ "data-slot=\"field-description\""
    assert html =~ "data-slot=\"field-message\""
    assert html =~ "data-slot=\"field-error\""
  end

  test "field_control carries invalid-state selectors for shared controls" do
    html =
      render_component(&Forms.field_control/1, %{
        inner_block: [%{inner_block: fn _, _ -> "stub" end}]
      })

    assert html =~ "data-slot=\"field-control\""
    assert html =~ "data-slot=select-trigger"
    assert html =~ "data-slot=native-select"
    assert html =~ "data-slot=autocomplete-input"
    assert html =~ "data-slot=combobox-input"
    assert html =~ "data-slot=switch"
    assert html =~ "data-slot=checkbox"
    assert html =~ "data-slot=radio-group-item"
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

    assert label_html =~ "data-slot=\"label\""
    assert label_html =~ "for=\"email\""
    assert field_label_html =~ "data-slot=\"field-label\""
    assert description_html =~ "data-slot=\"field-description\""
    assert description_html =~ "text-muted-foreground"
    assert message_html =~ "data-slot=\"field-message\""
    assert message_html =~ "text-foreground"
  end

  test "checkbox renders native input and label content" do
    html =
      render_component(&Forms.checkbox/1, %{
        id: "terms",
        checked: true,
        inner_block: CinderUI.TestHelpers.slot("Accept terms")
      })

    assert html =~ "data-slot=\"checkbox\""
    assert html =~ "checked"
    assert html =~ "Accept terms"
  end

  test "switch hides native checkbox glyph and renders thumb" do
    html = render_component(&Forms.switch/1, %{id: "marketing", checked: true})

    assert html =~ "data-slot=\"switch\""
    assert html =~ "data-slot=\"switch-thumb\""
    assert html =~ "appearance-none"
    assert html =~ "checked:bg-primary"
    assert html =~ "peer-checked:translate-x-[calc(100%-2px)]"
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

    assert html =~ "data-slot=\"slider\""
    assert html =~ "value=\"0.5\""
    assert html =~ "min=\"0.0\""
    assert html =~ "max=\"1.0\""
    assert html =~ "step=\"0.1\""
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

    assert html =~ "data-slot=\"radio-group\""
    assert html =~ "data-slot=\"radio-group-item\""
    assert html =~ "value=\"eu\""
    assert html =~ "disabled"
    assert html =~ "opacity-50"
  end

  test "input_otp renders hook-enabled segmented inputs" do
    html =
      render_component(&Forms.input_otp/1, %{
        name: "verification_code[]",
        length: 4,
        values: ["1", "", "3", ""]
      })

    assert html =~ "data-slot=\"input-otp\""
    assert html =~ "phx-hook=\"CuiInputOtp\""
    assert html =~ "data-input-otp-input"
    assert html =~ "data-input-otp-index=\"0\""
    assert html =~ "data-input-otp-index=\"3\""
    assert html =~ "value=\"1\""
    assert html =~ "value=\"3\""
    assert html =~ ~r/id="cinder-ui-input-otp-\d+"/
  end

  test "input_otp supports grouped separators" do
    html =
      render_component(&Forms.input_otp/1, %{
        name: "backup_code[]",
        length: 6,
        groups: [3, 3]
      })

    assert html =~ "data-slot=\"input-otp-separator\""
    assert html =~ "data-input-otp-separator-after=\"2\""
  end

  test "input_group renders a unified control shell" do
    html =
      render_component(&Forms.input_group/1, %{
        inner_block: [
          %{inner_block: fn _, _ -> "stub" end}
        ]
      })

    assert html =~ "data-slot=\"input-group\""
    assert html =~ "has-[:focus-visible]:ring-[3px]"
    assert html =~ "[&amp;&gt;[data-slot=input]]:border-0"
    assert html =~ "[&amp;&gt;[data-slot=button]]:border-0"
  end
end
