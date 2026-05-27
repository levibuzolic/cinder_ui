defmodule CinderUI.Components.Typography do
  @moduledoc """
  Named typography aliases for teams that prefer semantic component names.

  Import this module directly, or opt in through `use CinderUI, typography: true`,
  to make aliases such as `<.h1>`, `<.lead>`, and `<.inline_code>` available in
  templates. These aliases are not imported by `use CinderUI` by default because
  short names like `h1/1` are likely to conflict with application components.
  """

  use Phoenix.Component

  alias CinderUI.Components.Layout

  @doc "Renders the `:h1` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def h1(assigns), do: typography_alias(assigns, :h1)

  @doc "Renders the `:h2` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def h2(assigns), do: typography_alias(assigns, :h2)

  @doc "Renders the `:h3` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def h3(assigns), do: typography_alias(assigns, :h3)

  @doc "Renders the `:h4` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def h4(assigns), do: typography_alias(assigns, :h4)

  @doc "Renders the `:p` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def p(assigns), do: typography_alias(assigns, :p)

  @doc "Renders the `:lead` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def lead(assigns), do: typography_alias(assigns, :lead)

  @doc "Renders the `:large` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def large(assigns), do: typography_alias(assigns, :large)

  @doc "Renders the `:small` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def small(assigns), do: typography_alias(assigns, :small)

  @doc "Renders the `:muted` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def muted(assigns), do: typography_alias(assigns, :muted)

  @doc "Renders the `:blockquote` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def blockquote(assigns), do: typography_alias(assigns, :blockquote)

  @doc "Renders the `:inline_code` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def inline_code(assigns), do: typography_alias(assigns, :inline_code)

  @doc "Renders the `:list` typography variant."
  attr :as, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def list(assigns), do: typography_alias(assigns, :list)

  defp typography_alias(assigns, variant) do
    assigns
    |> assign(:variant, variant)
    |> Layout.typography()
  end
end
