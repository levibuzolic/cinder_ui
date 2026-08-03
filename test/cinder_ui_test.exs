defmodule CinderUI.DefaultImportProbe do
  use CinderUI

  @imports __ENV__.functions
  def imported_functions, do: @imports

  def render(assigns) do
    ~H"""
    <.typography variant={:lead}>Revenue overview</.typography>
    """
  end
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

defmodule CinderUI.ComponentsTypographyProbe do
  use CinderUI.Components, typography: true

  @imports __ENV__.functions
  def imported_functions, do: @imports
end

defmodule CinderUITest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "use CinderUI imports typography by default" do
    assert imported?(CinderUI.DefaultImportProbe, CinderUI.Components.Typography, :typography)

    html = render_component(&CinderUI.DefaultImportProbe.render/1, %{})

    assert html =~ "<p"
    assert html =~ ~s(data-variant="lead")
    assert html =~ "Revenue overview"
  end

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

  test "use CinderUI validates boolean options" do
    assert_raise ArgumentError, ~r/typography.*expects a boolean/, fn ->
      Code.compile_string("""
      defmodule CinderUI.InvalidTypographyProbe do
        use CinderUI, typography: :yes
      end
      """)
    end

    assert_raise ArgumentError, ~r/typography.*expects a boolean/, fn ->
      Code.compile_string("""
      defmodule CinderUI.InvalidComponentsTypographyProbe do
        use CinderUI.Components, typography: :yes
      end
      """)
    end
  end

  test "use CinderUI validates exclusions" do
    assert_raise ArgumentError, ~r/unknown component.*not_a_component/, fn ->
      Code.compile_string("""
      defmodule CinderUI.UnknownExclusionProbe do
        use CinderUI, except: [:not_a_component]
      end
      """)
    end
  end

  test "use CinderUI excludes selected components, including default typography" do
    module = Module.concat(CinderUI, "ExclusionProbe#{System.unique_integer([:positive])}")

    [{^module, _beam}] =
      Code.compile_string("""
      defmodule #{inspect(module)} do
        use CinderUI, except: [:button, :typography]

        @imports __ENV__.functions
        def imported_functions, do: @imports
      end
      """)

    refute imported?(module, CinderUI.Components.Actions, :button)
    refute imported?(module, CinderUI.Components.Typography, :typography)
  end

  test "use CinderUI.Components imports typography aliases when enabled" do
    assert imported?(
             CinderUI.ComponentsTypographyProbe,
             CinderUI.Components.Typography,
             :h1
           )
  end

  defp imported?(module, imported_module, function) do
    module.imported_functions()
    |> Keyword.get(imported_module, [])
    |> Enum.member?({function, 1})
  end
end
