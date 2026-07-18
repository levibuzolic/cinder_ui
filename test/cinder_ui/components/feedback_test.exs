defmodule CinderUI.Components.FeedbackTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Feedback
  alias CinderUI.TestHelpers

  test "badge renders color and variant" do
    html =
      render_component(&Feedback.badge/1, %{
        color: :secondary,
        variant: :solid,
        inner_block: TestHelpers.slot("New")
      })

    assert html =~ "data-slot=\"badge\""
    assert html =~ ~s(data-color="secondary")
    assert html =~ ~s(data-variant="solid")
    assert html =~ "New"
  end

  test "progress renders indicator transform" do
    html = render_component(&Feedback.progress/1, %{value: 50})
    assert html =~ "data-slot=\"progress\""
    assert html =~ "translateX(-50.0%)"
  end

  test "progress clamps its visual and accessible values to the configured range" do
    html = render_component(&Feedback.progress/1, %{value: 150, max: 80})

    assert TestHelpers.attr(html, "[data-slot='progress']", "aria-valuemax") == "80"
    assert TestHelpers.attr(html, "[data-slot='progress']", "aria-valuenow") == "80"
    assert html =~ "translateX(-0.0%)"
  end

  test "flash renders title when provided" do
    html =
      render_component(&Feedback.flash/1, %{
        kind: :info,
        flash: %{"info" => "Saved successfully"},
        title: "Saved"
      })

    assert html =~ ~s(data-slot="alert")
    assert html =~ ~s(data-slot="alert-title")
    assert html =~ ~s(data-slot="alert-description")
    assert html =~ ~s(role="alert")
    assert html =~ ~s(id="flash-info")
    assert html =~ "border-primary/20"
    assert html =~ "backdrop-blur-md"
    assert html =~ "Saved"
    assert html =~ "Saved successfully"
    assert html =~ "lv:clear-flash"
  end

  test "flash renders from inner block" do
    html =
      render_component(&Feedback.flash/1, %{
        kind: :error,
        inner_block: TestHelpers.slot("Inline message")
      })

    assert html =~ "Inline message"
    assert html =~ "circle-alert"
    refute html =~ ~s(data-slot="alert-description")
  end

  test "flash close button uses consistent aria-label casing" do
    html =
      render_component(&Feedback.flash/1, %{
        kind: :info,
        inner_block: TestHelpers.slot("Saved")
      })

    assert html =~ ~s(aria-label="Close")
    assert html =~ "inline-flex size-6 items-center justify-center"
  end

  test "flash supports success and warning kinds" do
    success_html =
      render_component(&Feedback.flash/1, %{
        kind: :success,
        inner_block: TestHelpers.slot("Workspace created")
      })

    warning_html =
      render_component(&Feedback.flash/1, %{
        kind: :warning,
        inner_block: TestHelpers.slot("Trial ends soon")
      })

    assert success_html =~ "circle-check-big"
    assert success_html =~ "border-success/30"
    assert warning_html =~ "triangle-alert"
    assert warning_html =~ "border-warning/30"
  end

  test "alert supports success and warning variants" do
    success_html =
      render_component(&Feedback.alert/1, %{
        variant: :success,
        inner_block: TestHelpers.slot(""),
        title: TestHelpers.slot("Success"),
        description: TestHelpers.slot("All good")
      })

    warning_html =
      render_component(&Feedback.alert/1, %{
        variant: :warning,
        inner_block: TestHelpers.slot(""),
        title: TestHelpers.slot("Warning"),
        description: TestHelpers.slot("Heads up")
      })

    assert success_html =~ ~s(data-variant="success")
    assert success_html =~ "border-success/30"
    assert success_html =~ "Success"
    assert success_html =~ "All good"
    assert warning_html =~ ~s(data-variant="warning")
    assert warning_html =~ "border-warning/30"
    assert warning_html =~ "Warning"
    assert warning_html =~ "Heads up"
  end

  test "flash_group renders drop-in ids and wrappers" do
    html = render_component(&Feedback.flash_group/1, %{flash: %{"info" => "Hi"}})

    assert html =~ "id=\"flash-group\""
    assert html =~ "id=\"flash-info\""
    assert html =~ "id=\"client-error\""
    assert html =~ "id=\"server-error\""
  end
end
