defmodule CinderUI.TailwindConfig do
  @moduledoc false

  # shadcn/ui design token colors that tailwind_merge needs to recognize
  # so it can properly deduplicate e.g. `bg-primary` vs `bg-green-600`.
  @shadcn_colors [
    "background",
    "foreground",
    "card",
    "card-foreground",
    "popover",
    "popover-foreground",
    "primary",
    "primary-foreground",
    "secondary",
    "secondary-foreground",
    "muted",
    "muted-foreground",
    "accent",
    "accent-foreground",
    "destructive",
    "destructive-foreground",
    "border",
    "input",
    "ring",
    "sidebar",
    "sidebar-foreground",
    "sidebar-primary",
    "sidebar-primary-foreground",
    "sidebar-accent",
    "sidebar-accent-foreground",
    "sidebar-border",
    "sidebar-ring"
  ]

  def config do
    TailwindMerge.Config.new(
      class_groups:
        TailwindMerge.Config.class_groups(
          colors: TailwindMerge.Config.colors() ++ @shadcn_colors
        )
    )
  end
end

defmodule CinderUI.Classes do
  @moduledoc """
  Utilities for composing Tailwind class lists.

  Uses `tailwind_merge` to intelligently resolve conflicting Tailwind utilities,
  so the last class in the list wins when there's a conflict (e.g. `bg-primary`
  vs `bg-green-600`).
  """

  use TailwindMerge, config: CinderUI.TailwindConfig.config()

  @doc """
  Joins classes from strings/lists while removing nil/false/empty values,
  then merges conflicting Tailwind utilities so the last one wins.
  """
  def classes(values) when is_list(values) do
    values
    |> List.flatten()
    |> Enum.filter(fn
      nil -> false
      false -> false
      "" -> false
      class when is_binary(class) -> true
      _ -> false
    end)
    |> Enum.join(" ")
    |> tw()
  end

  def classes(value), do: classes([value])

  @doc """
  Picks a class from a map keyed by atom/string variants.
  """
  def variant(map, key, fallback \\ nil) when is_map(map) do
    Map.get(map, key) || Map.get(map, to_string(key)) || fallback
  end
end
