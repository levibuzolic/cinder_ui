defmodule CinderUI.Docs.Recipes do
  @moduledoc false

  use CinderUI

  alias CinderUI.Docs.UIComponents.Code

  @auth_form_template Path.join([__DIR__, "recipes", "auth_form.html.heex"])
  @settings_page_template Path.join([__DIR__, "recipes", "settings_page.html.heex"])
  @admin_shell_template Path.join([__DIR__, "recipes", "admin_shell.html.heex"])

  @external_resource @auth_form_template
  @external_resource @settings_page_template
  @external_resource @admin_shell_template

  embed_templates "recipes/*"

  @recipes [
    %{
      id: "auth-form",
      title: "Auth form",
      summary: "A compact sign-in flow using card, field, input, and button composition.",
      source: File.read!(@auth_form_template),
      template: :auth_form
    },
    %{
      id: "settings-page",
      title: "Settings page",
      summary: "A LiveView-friendly settings layout with server-rendered form controls.",
      source: File.read!(@settings_page_template),
      template: :settings_page
    },
    %{
      id: "admin-shell",
      title: "Admin shell",
      summary: "A sidebar, table, and detail card composed into a small operational view.",
      source: File.read!(@admin_shell_template),
      template: :admin_shell
    }
  ]

  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."
  attr :rest, :global

  def recipes_page(assigns) do
    assigns = assign(assigns, :recipes, @recipes)

    ~H"""
    <div class="space-y-8" {@rest}>
      <section class="max-w-3xl">
        <h2 class="text-2xl font-semibold tracking-tight">Recipes</h2>
        <p class="text-muted-foreground mt-2 text-sm">
          Composed LiveView/Phoenix examples built from existing Cinder UI components.
          These are copyable blocks, not new primitives.
        </p>
      </section>

      <section class="grid gap-8">
        <.recipe_showcase :for={recipe <- @recipes} recipe={recipe} />
      </section>
    </div>
    """
  end

  attr :recipe, :map, required: true

  defp recipe_showcase(assigns) do
    assigns =
      assigns
      |> assign(:code_id, "code-recipe-#{assigns.recipe.id}")
      |> assign(:copy_id, "recipe-#{assigns.recipe.id}")

    ~H"""
    <article id={@recipe.id} class="overflow-hidden rounded-xl border">
      <header class="border-b p-4 sm:p-6">
        <div class="flex flex-wrap items-start justify-between gap-3">
          <div>
            <h3 class="text-base font-semibold">{@recipe.title}</h3>
            <p class="text-muted-foreground mt-1 text-sm">{@recipe.summary}</p>
          </div>
          <.badge variant={:outline}>Recipe</.badge>
        </div>
      </header>

      <div class="grid min-w-0 divide-y xl:grid-cols-[minmax(0,1fr)_minmax(26rem,0.8fr)] xl:divide-x xl:divide-y-0">
        <div class="bg-background min-w-0 p-4 sm:p-6">
          <.recipe_preview recipe={@recipe} />
        </div>

        <div class="relative min-w-0">
          <.button
            as="button"
            variant={:outline}
            size={:icon_sm}
            data-copy-template={@copy_id}
            aria-label="Copy HEEx"
            title="Copy HEEx"
            class="absolute top-2.5 right-2 z-10 bg-background/80"
          >
            <.icon name="copy" class="size-4" />
          </.button>
          <Code.docs_code_block
            id={@code_id}
            source={@recipe.source}
            language={:heex}
            pre_class="m-0 min-h-full rounded-none border-0 bg-muted/30 pr-12"
          />
        </div>
      </div>
    </article>
    """
  end

  attr :recipe, :map, required: true

  defp recipe_preview(%{recipe: %{template: :auth_form}} = assigns) do
    assigns = assign(assigns, :form, to_form(%{"email" => "", "password" => ""}, as: :user))

    ~H"""
    <div class="flex min-h-[30rem] items-center justify-center rounded-lg bg-muted/30 p-6">
      <.auth_form form={@form} />
    </div>
    """
  end

  defp recipe_preview(%{recipe: %{template: :settings_page}} = assigns) do
    ~H"""
    <div class="rounded-lg bg-muted/30 p-4 sm:p-6">
      <.settings_page />
    </div>
    """
  end

  defp recipe_preview(%{recipe: %{template: :admin_shell}} = assigns) do
    ~H"""
    <.admin_shell />
    """
  end
end
