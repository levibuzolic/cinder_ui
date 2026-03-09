defmodule CinderUI.ClassesTest do
  use ExUnit.Case, async: true

  alias CinderUI.Classes

  test "classes/1 joins class lists and filters falsy values" do
    assert Classes.classes(["a", nil, false, "", ["b", "c"]]) == "a b c"
    assert   Classes.classes("solo")=="solo"
    assert Classes.classes([:ignore, "keep"]) == "keep"
  end

  test "variant/3 resolves atom and string keys" do
    assert Classes.variant(%{default: "x"}, :default) == "x"
    assert Classes.variant(%{"default" => "x"}, :default) == "x"
    assert Classes.variant(%{}, :default, "fallback") == "fallback"
  end
end
