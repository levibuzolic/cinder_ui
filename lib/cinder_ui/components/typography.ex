defmodule CinderUI.Components.Typography do
  @moduledoc """
  Typography recipes for semantic headings and text treatments.

  `typography/1` is imported by `use CinderUI` by default. Named aliases such
  as `<.h1>`, `<.lead>`, and `<.inline_code>` are available when importing this
  module directly or by opting in through `use CinderUI, typography: true`.
  Aliases are opt-in because short names like `h1/1` are likely to conflict with
  application components.

  [View live Typography examples and component docs](https://levibuzolic.github.io/cinder_ui/docs/#typography).
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  @typography_variants [
    h1: %{
      tag: "h1",
      classes: "scroll-m-20 text-4xl font-extrabold leading-tight text-balance lg:text-5xl"
    },
    h2: %{
      tag: "h2",
      classes: "scroll-m-20 border-b pb-2 text-3xl font-semibold leading-tight first:mt-0"
    },
    h3: %{tag: "h3", classes: "scroll-m-20 text-2xl font-semibold leading-snug"},
    h4: %{tag: "h4", classes: "scroll-m-20 text-xl font-semibold leading-snug"},
    p: %{tag: "p", classes: "leading-7 [&:not(:first-child)]:mt-6"},
    lead: %{tag: "p", classes: "text-muted-foreground text-xl leading-7"},
    large: %{tag: "div", classes: "text-lg font-semibold leading-7"},
    small: %{tag: "small", classes: "text-sm leading-none font-medium"},
    muted: %{tag: "p", classes: "text-muted-foreground text-sm leading-normal"},
    blockquote: %{tag: "blockquote", classes: "border-l-2 pl-6 text-muted-foreground italic"},
    inline_code: %{
      tag: "code",
      classes:
        "bg-muted text-foreground rounded px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold"
    },
    list: %{tag: "ul", classes: "my-6 ml-6 list-disc [&>li]:mt-2"}
  ]
  @typography_variant_values Keyword.keys(@typography_variants)
  @typography_tag_values @typography_variants
                         |> Keyword.values()
                         |> Enum.map(& &1.tag)
                         |> Kernel.++(~w(h5 h6 ol span))
                         |> Enum.uniq()

  doc("""
  Shadcn-inspired typography recipe for semantic headings and text treatments.

  `typography/1` is intentionally small: it applies token-based Tailwind
  classes to a single semantic element and does not style arbitrary prose
  descendants. Use `as` when the visual treatment should render as a different
  HTML tag.

  ## Attributes

  - `variant`: `:h1 | :h2 | :h3 | :h4 | :p | :lead | :large | :small | :muted | :blockquote | :inline_code | :list`
  - `as`: optional HTML tag override for typography-safe text tags

  ## Examples

  ```heex title="Article heading stack" align="full" vrt
  <div class="max-w-2xl">
    <.typography variant={:h1}>Realtime payments need boring interfaces</.typography>
    <.typography variant={:lead} class="mt-4">
      Operators need clear hierarchy, calm defaults, and text that survives dense workflows.
    </.typography>
    <.typography>
      Use typography recipes when component copy needs consistent rhythm without introducing
      a rich text renderer or client-side dependency.
    </.typography>
  </div>
  ```

  ```heex title="Inline UI copy" align="full"
  <div class="max-w-md space-y-3">
    <.typography variant={:h3}>Workspace limits</.typography>
    <.typography variant={:muted}>
      API keys expire after <.typography variant={:inline_code}>90d</.typography>.
    </.typography>
    <.typography variant={:small} as="p">Last updated by the billing service.</.typography>
  </div>
  ```

  ```heex title="List recipe" align="full"
  <.typography variant={:list}>
    <li>Keep headings semantic.</li>
    <li>Use tokens like <.typography variant={:inline_code}>text-muted-foreground</.typography>.</li>
    <li>Reach for component slots before custom wrappers.</li>
  </.typography>
  ```
  """)

  attr :variant, :atom,
    default: :p,
    values: @typography_variant_values

  attr :as, :string, default: nil, values: [nil | @typography_tag_values]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def typography(assigns) do
    variant = Keyword.fetch!(@typography_variants, assigns.variant)

    assigns =
      assigns
      |> assign(:tag_name, assigns.as || variant.tag)
      |> assign(:classes, [
        variant.classes,
        assigns.class
      ])

    if assigns.variant == :inline_code and assigns.tag_name == "code" do
      ~H"""
      <code
        data-slot="typography"
        data-variant={@variant}
        class={classes(@classes)}
        {@rest}
      >{render_slot(@inner_block)}</code>
      """noformat
    else
      ~H"""
      <.dynamic_tag
        tag_name={@tag_name}
        data-slot="typography"
        data-variant={@variant}
        class={classes(@classes)}
        {@rest}
      >
        {render_slot(@inner_block)}
      </.dynamic_tag>
      """
    end
  end

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
    |> typography()
  end
end
