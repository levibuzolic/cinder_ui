defmodule CinderUI.Components.DelegationTest do
  use ExUnit.Case, async: false

  alias CinderUI.Components.Delegation

  test "components selects and combines component metadata" do
    components =
      Delegation.components([
        {CinderUI.Components.Forms.Controls, [:checkbox]},
        {CinderUI.Components.Forms.Select, [:select]}
      ])

    assert Map.keys(components) |> Enum.sort() == [:checkbox, :select]
  end

  test "component_doc reads source docs and rewrites facade links" do
    doc =
      Delegation.component_doc(
        CinderUI.Components.Forms.Controls,
        CinderUI.Components.Forms,
        :checkbox
      )

    assert doc =~ "Renders a checkbox"
    assert doc =~ "screenshots/forms-checkbox.png"

    assert doc =~
             "https://levibuzolic.github.io/cinder_ui/docs/forms-checkbox/"
  end

  test "component_doc falls back to compiled docs when source is unavailable" do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "cinder-ui-delegation-test-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(tmp_dir)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    File.cd!(tmp_dir, fn ->
      doc =
        Delegation.component_doc(
          CinderUI.Components.Actions,
          CinderUI.UI,
          :button
        )

      assert doc =~ "screenshots/ui-button.png"
      assert doc =~ "https://levibuzolic.github.io/cinder_ui/docs/ui-button/"

      assert Delegation.component_doc(
               CinderUI.Components.Actions,
               CinderUI.UI,
               :not_a_component
             ) == false
    end)
  end
end
