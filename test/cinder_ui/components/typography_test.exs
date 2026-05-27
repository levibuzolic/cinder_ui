defmodule CinderUI.Components.TypographyTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Typography
  alias CinderUI.TestHelpers

  test "typography renders semantic variant defaults" do
    html =
      render_component(&Typography.typography/1, %{
        variant: :h2,
        inner_block: TestHelpers.slot("Revenue overview")
      })

    assert html =~ "<h2"
    assert html =~ ~s(data-slot="typography")
    assert html =~ ~s(data-variant="h2")
    assert html =~ "Revenue overview"
    assert html =~ "text-3xl"
  end

  test "typography supports tag overrides" do
    html =
      render_component(&Typography.typography/1, %{
        variant: :small,
        as: "p",
        inner_block: TestHelpers.slot("Updated just now")
      })

    assert html =~ "<p"
    assert html =~ ~s(data-variant="small")
    assert html =~ "text-sm"
    refute html =~ "<small"
  end

  test "typography inline code does not add wrapper whitespace" do
    html =
      render_component(&Typography.typography/1, %{
        variant: :inline_code,
        inner_block: TestHelpers.slot("90d")
      })

    assert html =~ ~r/<code[^>]*>90d<\/code>/
  end

  test "heading aliases delegate to typography variants" do
    html =
      render_component(&Typography.h1/1, %{inner_block: TestHelpers.slot("Revenue overview")})

    assert html =~ "<h1"
    assert html =~ ~s(data-slot="typography")
    assert html =~ ~s(data-variant="h1")
    assert html =~ "Revenue overview"
    assert html =~ "text-4xl"
  end

  test "aliases preserve tag overrides" do
    html =
      render_component(&Typography.small/1, %{
        as: "p",
        inner_block: TestHelpers.slot("Updated just now")
      })

    assert html =~ "<p"
    assert html =~ ~s(data-variant="small")
    refute html =~ "<small"
  end

  test "inline_code alias does not add wrapper whitespace" do
    html = render_component(&Typography.inline_code/1, %{inner_block: TestHelpers.slot("90d")})

    assert html =~ ~r/<code[^>]*>90d<\/code>/
  end
end
