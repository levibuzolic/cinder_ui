defmodule CinderUI.Icons do
  @moduledoc """
  Optional Lucide icon integration for Cinder UI.

  This module exposes a single `icon/1` function component that dispatches to
  `lucide_icons` when the dependency is available.

  No sync task is required. Available icon names are read from
  `lucide_icons.icon_names/0` and cached automatically.

  Add `lucide_icons` to your application dependencies to enable icon rendering:

      {:lucide_icons, "~> 2.0"}

  If the dependency is missing, `icon/1` raises a descriptive error.

  ## Interactive docs

  [View live Icons examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#icons).
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  @lookup_cache_key {__MODULE__, :icon_lookup}

  doc("""
  Renders a Lucide icon by name.

  `name` accepts either kebab-case (`"chevron-down"`) or snake_case
  (`"chevron_down"`).

  ## Example

      <.icon name="chevron-down" class="size-4 text-muted-foreground" aria-hidden="true" />

  ## References

  - [Full Lucide icon directory](https://lucide.dev/icons)
  - [lucide_icons package](https://hex.pm/packages/lucide_icons)
  """)

  attr :name, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def icon(assigns) do
    module = lucide_icons_module()
    icon_name = normalize_icon_name(assigns.name)

    case resolve_icon(module, icon_name) do
      {:ok, icon_fun} ->
        apply(module, icon_fun, [icon_assigns(assigns)])

      {:error, :missing_dependency} ->
        raise ArgumentError, missing_dependency_message(assigns.name)

      {:error, :unknown_icon} ->
        raise ArgumentError, unknown_icon_message(module, icon_name)
    end
  end

  defp icon_assigns(assigns) do
    rest = Map.get(assigns, :rest, %{})
    changed = Map.get(assigns, :__changed__, %{})

    class =
      classes([
        "inline-block shrink-0 align-middle",
        Map.get(rest, :class) || Map.get(rest, "class"),
        assigns.class
      ])

    rest
    |> Map.drop([:class, "class"])
    |> maybe_put_class(class)
    |> Map.put_new(:__changed__, changed)
  end

  defp maybe_put_class(rest, ""), do: rest
  defp maybe_put_class(rest, nil), do: rest
  defp maybe_put_class(rest, class), do: Map.put(rest, :class, class)

  defp normalize_icon_name(name), do: name |> to_string() |> String.trim() |> String.downcase()

  defp resolve_icon(module, icon_name) do
    with true <- provider_available?(module),
         {:ok, icon_fun} <- lookup_icon_function(module, icon_name),
         true <- function_exported?(module, icon_fun, 1) do
      {:ok, icon_fun}
    else
      false -> {:error, :missing_dependency}
      {:error, :unknown_icon} -> {:error, :unknown_icon}
    end
  end

  defp provider_available?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :icon_names, 0)
  end

  defp lookup_icon_function(module, icon_name) do
    icon_lookup(module)
    |> Map.get(icon_name)
    |> case do
      nil -> {:error, :unknown_icon}
      icon_atom -> {:ok, icon_atom}
    end
  end

  defp icon_lookup(module) do
    cache_key = {@lookup_cache_key, module}

    case :persistent_term.get(cache_key, :missing) do
      :missing ->
        lookup = build_icon_lookup(module)
        :persistent_term.put(cache_key, lookup)
        lookup

      lookup ->
        lookup
    end
  end

  defp build_icon_lookup(module) do
    module
    |> :erlang.apply(:icon_names, [])
    |> Enum.reduce(%{}, fn icon_atom, acc ->
      snake_name = Atom.to_string(icon_atom)
      kebab_name = String.replace(snake_name, "_", "-")

      acc
      |> Map.put(snake_name, icon_atom)
      |> Map.put(kebab_name, icon_atom)
    end)
  end

  defp lucide_icons_module do
    Application.get_env(:cinder_ui, :lucide_icons_module, Lucideicons)
  end

  defp missing_dependency_message(name) do
    """
    CinderUI.Icons.icon/1 could not render #{inspect(name)} because optional dependency :lucide_icons is not available.

    Add this to your application `deps/0` and run `mix deps.get`:

        {:lucide_icons, "~> 2.0"}

    If you do not want icon support, remove usages of `<.icon ... />`.
    """
    |> String.trim()
  end

  defp unknown_icon_message(module, icon_name) do
    search_query = String.replace(icon_name, "-", "_")

    hints =
      if function_exported?(module, :search_icons, 1) do
        module
        |> :erlang.apply(:search_icons, [search_query])
        |> Enum.take(5)
        |> Enum.map(&"`#{Atom.to_string(&1) |> String.replace("_", "-")}`")
      else
        []
      end

    suggestion =
      case hints do
        [] -> ""
        values -> "\n\nDid you mean: " <> Enum.join(values, ", ")
      end

    """
    CinderUI.Icons.icon/1 received unknown icon name #{inspect(icon_name)}.
    Verify the icon exists in lucide_icons.
    #{suggestion}
    """
    |> String.trim()
  end
end
