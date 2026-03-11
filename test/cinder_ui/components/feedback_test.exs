defmodule CinderUI.Components.FeedbackTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Feedback
  alias CinderUI.TestHelpers

  test "badge renders variant" do
    html =
      render_component(&Feedback.badge/1, %{
        variant: :secondary,
        inner_block: TestHelpers.slot("New")
      })

    assert html =~ "data-slot=\"badge\""
    assert html =~ "New"
  end

  test "progress renders indicator transform" do
    html = render_component(&Feedback.progress/1, %{value: 50})
    assert html =~ "data-slot=\"progress\""
    assert html =~ "translateX(-50.0%)"
  end

  test "flash renders title when provided" do
    html =
      render_component(&Feedback.flash/1, %{
        kind: :info,
        flash: %{"info" => "Saved successfully"},
        title: "Saved"
      })

    assert html =~ ~s(role="alert")
    assert html =~ ~s(id="flash-info")
    assert html =~ "border-primary/20"
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
  end

  test "flash close button uses consistent aria-label casing" do
    html =
      render_component(&Feedback.flash/1, %{
        kind: :info,
        inner_block: TestHelpers.slot("Saved")
      })

    assert html =~ ~s(aria-label="Close")
  end

  test "flash_group renders drop-in ids and wrappers" do
    html = render_component(&Feedback.flash_group/1, %{flash: %{"info" => "Hi"}})

    assert html =~ "id=\"flash-group\""
    assert html =~ "id=\"flash-info\""
    assert html =~ "id=\"client-error\""
    assert html =~ "id=\"server-error\""
  end
end
