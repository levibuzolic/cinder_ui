defmodule CinderUI.Docs.Recipes do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Components.Actions
  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Docs.UIComponents.Code
  alias CinderUI.Icons

  @auth_form_source ~S"""
  <.card class="mx-auto max-w-sm">
    <.card_header>
      <.card_title>Sign in</.card_title>
      <.card_description>Use your workspace account to continue.</.card_description>
    </.card_header>
    <.card_content>
      <.form for={@form} phx-submit="sign_in" class="grid gap-4">
        <.field>
          <:label for="user_email">Email</:label>
          <.input id="user_email" field={@form[:email]} type="email" placeholder="team@example.com" />
        </.field>
        <.field>
          <:label for="user_password">Password</:label>
          <.input id="user_password" field={@form[:password]} type="password" />
        </.field>
        <.button class="w-full">Sign in</.button>
      </.form>
    </.card_content>
  </.card>
  """

  @settings_source ~S"""
  <div class="grid gap-6 lg:grid-cols-[12rem_1fr]">
    <nav class="flex flex-col gap-1 text-sm">
      <.button variant={:ghost} class="justify-start">Profile</.button>
      <.button variant={:ghost} class="justify-start">Notifications</.button>
      <.button variant={:ghost} class="justify-start">Billing</.button>
    </nav>

    <.card>
      <.card_header>
        <.card_title>Workspace settings</.card_title>
        <.card_description>Manage defaults for new members.</.card_description>
      </.card_header>
      <.card_content class="grid gap-5">
        <.field>
          <:label for="workspace_name">Workspace name</:label>
          <.input id="workspace_name" name="workspace[name]" value="Acme Operations" />
        </.field>
        <.field>
          <:label for="workspace_region">Default region</:label>
          <.select id="workspace_region" name="workspace[region]" value="au">
            <:option value="au" label="Australia" />
            <:option value="us" label="United States" />
            <:option value="eu" label="Europe" />
          </.select>
        </.field>
      <.field class="flex-row items-center justify-between rounded-lg border p-4">
        <:label for="workspace_digest">Weekly digest</:label>
        <:description>Send a Monday summary to workspace admins.</:description>
        <.switch id="workspace_digest" name="workspace[digest]" checked />
      </.field>
      </.card_content>
      <.card_footer class="justify-end border-t">
        <.button variant={:outline}>Cancel</.button>
        <.button>Save changes</.button>
      </.card_footer>
    </.card>
  </div>
  """

  @admin_source ~S"""
  <.sidebar_layout collapsible={:none} class="min-h-[32rem] rounded-xl border">
    <:sidebar content_class="px-3 py-4">
      <.sidebar_group label="Admin">
        <.sidebar_item icon="layout-dashboard" current>Customers</.sidebar_item>
        <.sidebar_item icon="receipt-text">Invoices</.sidebar_item>
        <.sidebar_item icon="settings">Settings</.sidebar_item>
      </.sidebar_group>
    </:sidebar>

    <:main class="min-w-0 p-6">
      <div class="grid gap-6 xl:grid-cols-[1fr_20rem]">
        <.card>
          <.card_header>
            <.card_title>Customers</.card_title>
            <.card_action><.button size={:sm}>Add customer</.button></.card_action>
            <.card_description>Recent customer activity and account health.</.card_description>
          </.card_header>
          <.card_content>
            <.table>
              <.table_header>
                <.table_row>
                  <.table_head>Customer</.table_head>
                  <.table_head>Status</.table_head>
                  <.table_head class="text-right">Spend</.table_head>
                </.table_row>
              </.table_header>
              <.table_body>
                <.table_row>
                  <.table_cell>Northstar Studio</.table_cell>
                  <.table_cell><.badge color={:success} variant={:outline}>Active</.badge></.table_cell>
                  <.table_cell class="text-right">$12,400</.table_cell>
                </.table_row>
                <.table_row>
                  <.table_cell>Atlas Labs</.table_cell>
                  <.table_cell><.badge color={:warning} variant={:outline}>Review</.badge></.table_cell>
                  <.table_cell class="text-right">$8,920</.table_cell>
                </.table_row>
              </.table_body>
            </.table>
          </.card_content>
        </.card>

        <.card>
          <.card_header>
            <.card_title>Northstar Studio</.card_title>
            <.card_description>Primary account owner and next steps.</.card_description>
          </.card_header>
          <.card_content class="grid gap-4">
            <.avatar fallback="NS" />
            <p class="text-sm text-muted-foreground">Renewal review due in 14 days.</p>
            <.button variant={:outline} class="w-full">Open profile</.button>
          </.card_content>
        </.card>
      </div>
    </:main>
  </.sidebar_layout>
  """

  @recipes [
    %{
      id: "auth-form",
      title: "Auth form",
      summary: "A compact sign-in flow using card, field, input, and button composition.",
      source: @auth_form_source
    },
    %{
      id: "settings-page",
      title: "Settings page",
      summary: "A LiveView-friendly settings layout with server-rendered form controls.",
      source: @settings_source
    },
    %{
      id: "admin-shell",
      title: "Admin shell",
      summary: "A sidebar, table, and detail card composed into a small operational view.",
      source: @admin_source
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
          <Feedback.badge variant={:outline}>Recipe</Feedback.badge>
        </div>
      </header>

      <div class="grid min-w-0 divide-y xl:grid-cols-[minmax(0,1fr)_minmax(26rem,0.8fr)] xl:divide-x xl:divide-y-0">
        <div class="bg-background min-w-0 p-4 sm:p-6">
          <.recipe_preview recipe_id={@recipe.id} />
        </div>

        <div class="relative min-w-0">
          <Actions.button
            as="button"
            variant={:outline}
            size={:icon_sm}
            data-copy-template={@copy_id}
            aria-label="Copy HEEx"
            title="Copy HEEx"
            class="absolute top-2.5 right-2 z-10 bg-background/80"
          >
            <Icons.icon name="copy" class="size-4" />
          </Actions.button>
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

  attr :recipe_id, :string, required: true

  defp recipe_preview(%{recipe_id: "auth-form"} = assigns) do
    ~H"""
    <div class="flex min-h-[30rem] items-center justify-center rounded-lg bg-muted/30 p-6">
      <Layout.card class="w-full max-w-sm">
        <Layout.card_header>
          <Layout.card_title>Sign in</Layout.card_title>
          <Layout.card_description>Use your workspace account to continue.</Layout.card_description>
        </Layout.card_header>
        <Layout.card_content>
          <form class="grid gap-4">
            <Forms.field>
              <:label for="recipe-auth-email">Email</:label>
              <Forms.input
                id="recipe-auth-email"
                name="user[email]"
                type="email"
                placeholder="team@example.com"
              />
            </Forms.field>
            <Forms.field>
              <:label for="recipe-auth-password">Password</:label>
              <Forms.input id="recipe-auth-password" name="user[password]" type="password" />
            </Forms.field>
            <Actions.button class="w-full">Sign in</Actions.button>
          </form>
        </Layout.card_content>
      </Layout.card>
    </div>
    """
  end

  defp recipe_preview(%{recipe_id: "settings-page"} = assigns) do
    ~H"""
    <div class="rounded-lg bg-muted/30 p-4 sm:p-6">
      <div class="grid gap-6 lg:grid-cols-[12rem_1fr]">
        <nav class="flex flex-col gap-1 text-sm">
          <Actions.button variant={:ghost} class="justify-start">Profile</Actions.button>
          <Actions.button variant={:ghost} class="justify-start">Notifications</Actions.button>
          <Actions.button variant={:ghost} class="justify-start">Billing</Actions.button>
        </nav>

        <Layout.card>
          <Layout.card_header>
            <Layout.card_title>Workspace settings</Layout.card_title>
            <Layout.card_description>Manage defaults for new members.</Layout.card_description>
          </Layout.card_header>
          <Layout.card_content class="grid gap-5">
            <Forms.field>
              <:label for="recipe-workspace-name">Workspace name</:label>
              <Forms.input
                id="recipe-workspace-name"
                name="workspace[name]"
                value="Acme Operations"
              />
            </Forms.field>
            <Forms.field>
              <:label for="recipe-workspace-region">Default region</:label>
              <Forms.select id="recipe-workspace-region" name="workspace[region]" value="au">
                <:option value="au" label="Australia" />
                <:option value="us" label="United States" />
                <:option value="eu" label="Europe" />
              </Forms.select>
            </Forms.field>
            <Forms.field class="flex-row items-center justify-between rounded-lg border p-4">
              <:label for="recipe-workspace-digest">Weekly digest</:label>
              <:description>Send a Monday summary to workspace admins.</:description>
              <Forms.switch id="recipe-workspace-digest" name="workspace[digest]" checked />
            </Forms.field>
          </Layout.card_content>
          <Layout.card_footer class="justify-end border-t">
            <Actions.button variant={:outline}>Cancel</Actions.button>
            <Actions.button>Save changes</Actions.button>
          </Layout.card_footer>
        </Layout.card>
      </div>
    </div>
    """
  end

  defp recipe_preview(%{recipe_id: "admin-shell"} = assigns) do
    ~H"""
    <Advanced.sidebar_layout collapsible={:none} class="min-h-[32rem] rounded-xl border">
      <:sidebar content_class="px-3 py-4">
        <Advanced.sidebar_group label="Admin">
          <Advanced.sidebar_item icon="layout-dashboard" current>Customers</Advanced.sidebar_item>
          <Advanced.sidebar_item icon="receipt-text">Invoices</Advanced.sidebar_item>
          <Advanced.sidebar_item icon="settings">Settings</Advanced.sidebar_item>
        </Advanced.sidebar_group>
      </:sidebar>

      <:main class="min-w-0 p-6">
        <div class="grid gap-6 xl:grid-cols-[1fr_20rem]">
          <Layout.card>
            <Layout.card_header>
              <Layout.card_title>Customers</Layout.card_title>
              <Layout.card_action>
                <Actions.button size={:sm}>Add customer</Actions.button>
              </Layout.card_action>
              <Layout.card_description>
                Recent customer activity and account health.
              </Layout.card_description>
            </Layout.card_header>
            <Layout.card_content>
              <DataDisplay.table>
                <DataDisplay.table_header>
                  <DataDisplay.table_row>
                    <DataDisplay.table_head>Customer</DataDisplay.table_head>
                    <DataDisplay.table_head>Status</DataDisplay.table_head>
                    <DataDisplay.table_head class="text-right">Spend</DataDisplay.table_head>
                  </DataDisplay.table_row>
                </DataDisplay.table_header>
                <DataDisplay.table_body>
                  <DataDisplay.table_row>
                    <DataDisplay.table_cell>Northstar Studio</DataDisplay.table_cell>
                    <DataDisplay.table_cell>
                      <Feedback.badge color={:success} variant={:outline}>Active</Feedback.badge>
                    </DataDisplay.table_cell>
                    <DataDisplay.table_cell class="text-right">$12,400</DataDisplay.table_cell>
                  </DataDisplay.table_row>
                  <DataDisplay.table_row>
                    <DataDisplay.table_cell>Atlas Labs</DataDisplay.table_cell>
                    <DataDisplay.table_cell>
                      <Feedback.badge color={:warning} variant={:outline}>Review</Feedback.badge>
                    </DataDisplay.table_cell>
                    <DataDisplay.table_cell class="text-right">$8,920</DataDisplay.table_cell>
                  </DataDisplay.table_row>
                </DataDisplay.table_body>
              </DataDisplay.table>
            </Layout.card_content>
          </Layout.card>

          <Layout.card>
            <Layout.card_header>
              <Layout.card_title>Northstar Studio</Layout.card_title>
              <Layout.card_description>Primary account owner and next steps.</Layout.card_description>
            </Layout.card_header>
            <Layout.card_content class="grid gap-4">
              <DataDisplay.avatar fallback="NS" />
              <p class="text-sm text-muted-foreground">Renewal review due in 14 days.</p>
              <Actions.button variant={:outline} class="w-full">Open profile</Actions.button>
            </Layout.card_content>
          </Layout.card>
        </div>
      </:main>
    </Advanced.sidebar_layout>
    """
  end

  defp recipe_preview(assigns) do
    ~H"""
    <Feedback.empty_state>
      <:title>Recipe unavailable</:title>
    </Feedback.empty_state>
    """
  end
end
