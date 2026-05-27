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

  @data_table_source ~S"""
  <% filter = @filter || "" %>
  <% sort = @sort || %{by: :number, dir: :asc} %>
  <% selected_ids = @selected_ids || MapSet.new([1002]) %>
  <% page = @page || %{number: 1, total: 4, prev_path: nil, next_path: "/orders?page=2"} %>
  <% orders = @orders || [
    %{id: 1001, number: "ORD-1001", customer: "Mira Chen", status: :paid, total: "$240.00"},
    %{id: 1002, number: "ORD-1002", customer: "Ari Patel", status: :pending, total: "$88.50"},
    %{id: 1003, number: "ORD-1003", customer: "Levi Buzolic", status: :paid, total: "$149.00"}
  ] %>

  <div class="space-y-4">
    <form phx-change="filter" phx-submit="filter" class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
      <.input
        id="orders-filter"
        name="q"
        value={filter}
        placeholder="Filter orders..."
        class="sm:max-w-xs"
      />
      <.button type="submit" variant={:outline} size={:sm}>Apply filters</.button>
    </form>

    <.table>
      <.table_caption>
        Showing page {page.number} of {page.total}. Sorting and filtering stay in LiveView assigns.
      </.table_caption>
      <.table_header>
        <.table_row>
          <.table_head class="w-10">
            <.checkbox id="select-all-orders" name="select_all" aria-label="Select all orders" />
          </.table_head>
          <.table_head>
            <.button
              type="button"
              variant={:ghost}
              size={:sm}
              class="-ml-3"
              phx-click="sort"
              phx-value-by="number"
            >
              Order
              <.icon :if={sort.by == :number && sort.dir == :asc} name="chevron-up" class="size-3" />
              <.icon :if={sort.by == :number && sort.dir == :desc} name="chevron-down" class="size-3" />
            </.button>
          </.table_head>
          <.table_head>Customer</.table_head>
          <.table_head>Status</.table_head>
          <.table_head class="text-right">Total</.table_head>
          <.table_head class="w-10"><span class="sr-only">Actions</span></.table_head>
        </.table_row>
      </.table_header>
      <.table_body>
        <.table_row :for={order <- orders} state={if MapSet.member?(selected_ids, order.id), do: "selected"}>
          <.table_cell>
            <.checkbox
              id={"select-order-" <> to_string(order.id)}
              name="selected_order_ids[]"
              value={to_string(order.id)}
              checked={MapSet.member?(selected_ids, order.id)}
              aria-label={"Select " <> order.number}
            />
          </.table_cell>
          <.table_cell class="font-medium">{order.number}</.table_cell>
          <.table_cell>{order.customer}</.table_cell>
          <.table_cell>
            <.badge color={if(order.status == :paid, do: :success, else: :warning)} variant={:outline}>
              {Phoenix.Naming.humanize(order.status)}
            </.badge>
          </.table_cell>
          <.table_cell class="text-right">{order.total}</.table_cell>
          <.table_cell>
            <.button
              type="button"
              variant={:ghost}
              size={:icon}
              aria-label={"Open actions for " <> order.number}
            >
              <.icon name="ellipsis-vertical" class="size-4" />
            </.button>
          </.table_cell>
        </.table_row>
      </.table_body>
    </.table>

    <.pagination>
      <.pagination_content>
        <.pagination_item>
          <.pagination_previous href={page.prev_path || "#"} aria-disabled={is_nil(page.prev_path)} />
        </.pagination_item>
        <.pagination_item>
          <.pagination_link href="#" active>{page.number}</.pagination_link>
        </.pagination_item>
        <.pagination_item><.pagination_ellipsis /></.pagination_item>
        <.pagination_item>
          <.pagination_link href={"/orders?page=" <> to_string(page.total)}>{page.total}</.pagination_link>
        </.pagination_item>
        <.pagination_item>
          <.pagination_next href={page.next_path || "#"} aria-disabled={is_nil(page.next_path)} />
        </.pagination_item>
      </.pagination_content>
    </.pagination>
  </div>
  """

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
    },
    %{
      id: "data-table",
      title: "Data table",
      summary:
        "A LiveView-managed orders table with server-owned filtering, sorting, selection, and paging.",
      source: @data_table_source,
      template: :data_table
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

  defp recipe_preview(%{recipe: %{template: :data_table}} = assigns) do
    assigns =
      assign(assigns,
        filter: "",
        sort: %{by: :number, dir: :asc},
        selected_ids: MapSet.new([1002]),
        page: %{number: 1, total: 4, prev_path: nil, next_path: "/orders?page=2"},
        orders: [
          %{id: 1001, number: "ORD-1001", customer: "Mira Chen", status: :paid, total: "$240.00"},
          %{
            id: 1002,
            number: "ORD-1002",
            customer: "Ari Patel",
            status: :pending,
            total: "$88.50"
          },
          %{
            id: 1003,
            number: "ORD-1003",
            customer: "Levi Buzolic",
            status: :paid,
            total: "$149.00"
          }
        ]
      )

    ~H"""
    <div class="space-y-4 rounded-lg bg-muted/30 p-4 sm:p-6">
      <form class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <.input
          id="recipe-orders-filter"
          name="q"
          value={@filter}
          placeholder="Filter orders..."
          class="sm:max-w-xs"
        />
        <.button type="submit" variant={:outline} size={:sm}>Apply filters</.button>
      </form>

      <.table>
        <.table_caption>
          Showing page {@page.number} of {@page.total}. Sorting and filtering stay in LiveView assigns.
        </.table_caption>
        <.table_header>
          <.table_row>
            <.table_head class="w-10">
              <.checkbox
                id="recipe-select-all-orders"
                name="select_all"
                aria-label="Select all orders"
              />
            </.table_head>
            <.table_head>
              <.button
                type="button"
                variant={:ghost}
                size={:sm}
                class="-ml-3"
              >
                Order
                <.icon
                  :if={@sort.by == :number && @sort.dir == :asc}
                  name="chevron-up"
                  class="size-3"
                />
              </.button>
            </.table_head>
            <.table_head>Customer</.table_head>
            <.table_head>Status</.table_head>
            <.table_head class="text-right">Total</.table_head>
            <.table_head class="w-10">
              <span class="sr-only">Actions</span>
            </.table_head>
          </.table_row>
        </.table_header>
        <.table_body>
          <.table_row
            :for={order <- @orders}
            state={if MapSet.member?(@selected_ids, order.id), do: "selected"}
          >
            <.table_cell>
              <.checkbox
                id={"recipe-select-order-" <> to_string(order.id)}
                name="selected_order_ids[]"
                value={to_string(order.id)}
                checked={MapSet.member?(@selected_ids, order.id)}
                aria-label={"Select " <> order.number}
              />
            </.table_cell>
            <.table_cell class="font-medium">{order.number}</.table_cell>
            <.table_cell>{order.customer}</.table_cell>
            <.table_cell>
              <.badge
                color={if(order.status == :paid, do: :success, else: :warning)}
                variant={:outline}
              >
                {Phoenix.Naming.humanize(order.status)}
              </.badge>
            </.table_cell>
            <.table_cell class="text-right">{order.total}</.table_cell>
            <.table_cell>
              <.button
                type="button"
                variant={:ghost}
                size={:icon}
                aria-label={"Open actions for " <> order.number}
              >
                <.icon name="ellipsis-vertical" class="size-4" />
              </.button>
            </.table_cell>
          </.table_row>
        </.table_body>
      </.table>

      <.pagination>
        <.pagination_content>
          <.pagination_item>
            <.pagination_previous
              href={@page.prev_path || "#"}
              aria-disabled={is_nil(@page.prev_path)}
            />
          </.pagination_item>
          <.pagination_item>
            <.pagination_link href="#" active>{@page.number}</.pagination_link>
          </.pagination_item>
          <.pagination_item><.pagination_ellipsis /></.pagination_item>
          <.pagination_item>
            <.pagination_link href={"/orders?page=" <> to_string(@page.total)}>
              {@page.total}
            </.pagination_link>
          </.pagination_item>
          <.pagination_item>
            <.pagination_next
              href={@page.next_path || "#"}
              aria-disabled={is_nil(@page.next_path)}
            />
          </.pagination_item>
        </.pagination_content>
      </.pagination>
    </div>
    """
  end
end
