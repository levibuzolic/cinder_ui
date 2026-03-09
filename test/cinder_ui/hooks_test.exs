defmodule CinderUI.HooksTest do
  use ExUnit.Case, async: true

  alias CinderUI.Hooks
  alias CinderUI.JS
  alias Phoenix.HTML.Safe

  defp render_js(js) do
    js
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  test "app_js_snippet returns hook integration snippet" do
    snippet = Hooks.app_js_snippet()

    assert snippet =~ "import { CinderUIHooks } from \"./cinder_ui\""
    assert snippet =~ "Object.assign(Hooks, CinderUIHooks)"
  end

  test "dispatch_command emits the shared command event" do
    command =
      JS.dispatch_command(:open, to: "#account-dialog")
      |> render_js()

    assert command =~ "&quot;event&quot;:&quot;cinder-ui:command&quot;"
    assert command =~ "&quot;to&quot;:&quot;#account-dialog&quot;"
    assert command =~ "&quot;command&quot;:&quot;open&quot;"
  end

  test "command helpers preserve additional detail" do
    command =
      JS.toggle(to: "#owner-select", detail: %{source: "test"})
      |> render_js()

    assert command =~ "&quot;command&quot;:&quot;toggle&quot;"
    assert command =~ "&quot;source&quot;:&quot;test&quot;"
  end
end
