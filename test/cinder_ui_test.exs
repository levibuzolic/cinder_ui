defmodule CinderUI.DefaultImportProbe do
  use CinderUI

  @imports __ENV__.functions
  def imported_functions, do: @imports
end

defmodule CinderUI.TypographyOptInProbe do
  use CinderUI, typography: true

  def render(assigns) do
    ~H"""
    <.h1>Revenue overview</.h1>
    """
  end
end

defmodule CinderUI.TypographyAliasProbe do
  use CinderUI

  alias CinderUI.Components.Typography

  def render(assigns) do
    ~H"""
    <Typography.h1>Revenue overview</Typography.h1>
    """
  end
end

defmodule CinderUITest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "use CinderUI does not import shorthand typography aliases by default" do
    refute imported?(CinderUI.DefaultImportProbe, CinderUI.Components.Typography, :h1)
  end

  test "use CinderUI can opt in to shorthand typography aliases" do
    html = render_component(&CinderUI.TypographyOptInProbe.render/1, %{})

    assert html =~ "<h1"
    assert html =~ ~s(data-variant="h1")
    assert html =~ "Revenue overview"
  end

  test "typography aliases can be used through a module alias" do
    html = render_component(&CinderUI.TypographyAliasProbe.render/1, %{})

    assert html =~ "<h1"
    assert html =~ ~s(data-variant="h1")
    assert html =~ "Revenue overview"
  end

  defp imported?(module, imported_module, function) do
    module.imported_functions()
    |> Keyword.get(imported_module, [])
    |> Enum.member?({function, 1})
  end
end
