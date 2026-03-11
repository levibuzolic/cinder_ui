defmodule CinderUI.ClassesTest do
  use ExUnit.Case, async: true

  alias CinderUI.Classes

  test "classes/1 joins class lists and filters falsy values" do
    assert Classes.classes(["a", nil, false, "", ["b", "c"]]) == "a b c"
    assert Classes.classes("solo") == "solo"
    assert Classes.classes([:ignore, "keep"]) == "keep"
  end

  test "variant/3 resolves atom and string keys" do
    assert Classes.variant(%{default: "x"}, :default) == "x"
    assert Classes.variant(%{"default" => "x"}, :default) == "x"
    assert Classes.variant(%{}, :default, "fallback") == "fallback"
  end

  describe "tailwind merge" do
    test "last standard color wins over earlier standard color" do
      assert Classes.classes(["bg-red-500", "bg-blue-500"]) == "bg-blue-500"
    end

    test "shadcn token overrides standard Tailwind color" do
      assert Classes.classes(["bg-red-500", "bg-primary"]) == "bg-primary"
    end

    test "standard Tailwind color overrides shadcn token" do
      assert Classes.classes(["bg-primary", "bg-green-600"]) == "bg-green-600"
    end

    test "shadcn token overrides another shadcn token" do
      assert Classes.classes(["bg-primary", "bg-destructive"]) == "bg-destructive"
    end

    test "text color merging with shadcn tokens" do
      assert Classes.classes(["text-foreground", "text-muted-foreground"]) ==
               "text-muted-foreground"
    end

    test "shorthand padding overrides axis-specific padding" do
      assert Classes.classes(["px-2 py-1", "p-3"]) == "p-3"
    end

    test "dark variant preserved when overriding base" do
      result = Classes.classes(["bg-primary", "bg-green-600 dark:bg-green-800"])
      assert result == "bg-green-600 dark:bg-green-800"
    end

    test "non-conflicting classes are all preserved" do
      assert Classes.classes(["font-bold text-sm", "bg-primary rounded-md"]) ==
               "font-bold text-sm bg-primary rounded-md"
    end

    test "user class overrides component default in list order" do
      # Simulates component pattern: base classes first, user class last
      base = "bg-primary text-primary-foreground ring-2 ring-background"
      user = "bg-green-600 dark:bg-green-800"

      result = Classes.classes([base, user])
      assert result =~ "bg-green-600"
      assert result =~ "dark:bg-green-800"
      refute result =~ "bg-primary"
      assert result =~ "text-primary-foreground"
      assert result =~ "ring-2"
    end
  end
end
