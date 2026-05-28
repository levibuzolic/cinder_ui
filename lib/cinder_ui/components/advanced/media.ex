defmodule CinderUI.Components.Advanced.Media do
  @moduledoc false
  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  alias CinderUI.Icons

  doc("""
  Carousel shell.

  Render slides in `:item` slots and wire interactions with a LiveView hook or
  external script.

  ## Example

  ```heex title="Carousel" align="full"
  <.carousel id="feature-carousel">
    <:item><div class="rounded-md bg-muted p-8 text-sm">Slide one</div></:item>
    <:item><div class="rounded-md bg-muted/60 p-8 text-sm">Slide two</div></:item>
  </.carousel>
  ```

  ```heex title="Autoplay with indicators" align="full"
  <.carousel id="marketing-carousel" autoplay={4000} indicators={true}>
    <:item><div class="rounded-md bg-muted p-8 text-sm">Overview</div></:item>
    <:item><div class="rounded-md bg-muted/60 p-8 text-sm">Analytics</div></:item>
    <:item><div class="rounded-md bg-muted/40 p-8 text-sm">Deployments</div></:item>
  </.carousel>
  ```
  """)

  attr :id, :string, required: true
  attr :autoplay, :integer, default: nil
  attr :indicators, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :item, required: true

  def carousel(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative", assigns.class])
      |> assign(:item_count, length(assigns.item))

    ~H"""
    <div
      id={@id}
      data-slot="carousel"
      data-autoplay={@autoplay}
      role="region"
      aria-roledescription="carousel"
      class={classes(@classes)}
      phx-hook="CuiCarousel"
      {@rest}
    >
      <div data-slot="carousel-content" class="overflow-hidden">
        <div class="flex" data-carousel-track>
          <div
            :for={item <- @item}
            data-slot="carousel-item"
            role="group"
            aria-roledescription="slide"
            class="min-w-0 shrink-0 grow-0 basis-full"
          >
            {render_slot(item)}
          </div>
        </div>
      </div>

      <button
        type="button"
        data-slot="carousel-previous"
        data-carousel-prev
        aria-label="Previous slide"
        class="absolute left-2 top-1/2 -translate-y-1/2 rounded-full border bg-background p-2"
      >
        <Icons.icon name="chevron-left" class="size-4" />
      </button>
      <button
        type="button"
        data-slot="carousel-next"
        data-carousel-next
        aria-label="Next slide"
        class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full border bg-background p-2"
      >
        <Icons.icon name="chevron-right" class="size-4" />
      </button>

      <div
        :if={@indicators and @item_count > 1}
        data-slot="carousel-indicators"
        class="mt-4 flex items-center justify-center gap-2"
      >
        <button
          :for={index <- Enum.to_list(0..(@item_count - 1))}
          type="button"
          data-slot="carousel-indicator"
          data-carousel-indicator={index}
          data-active={index == 0}
          aria-label={"Go to slide #{index + 1}"}
          class="bg-muted-foreground/30 data-[active=true]:bg-primary h-2.5 w-2.5 rounded-full transition-colors"
        />
      </div>
    </div>
    """
  end

  doc("""
  Chart frame component for wrapping chart libraries with shadcn tokens.

  ## Example

  ```heex title="Chart shell" align="full"
  <.chart>
    <:title>Traffic</:title>
    <:description>Requests over the last 7 days.</:description>
    <div class="h-40 rounded-md bg-muted/60"></div>
  </.chart>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :title
  slot :description
  slot :inner_block, required: true

  def chart(assigns) do
    assigns = assign(assigns, :classes, ["rounded-xl border bg-card p-4", assigns.class])

    ~H"""
    <section data-slot="chart" class={classes(@classes)} {@rest}>
      <header :if={@title != [] or @description != []} class="mb-4">
        <h3 :if={@title != []} class="text-sm font-semibold">{render_slot(@title)}</h3>
        <p :if={@description != []} class="text-muted-foreground text-sm">
          {render_slot(@description)}
        </p>
      </header>
      <div data-slot="chart-content">{render_slot(@inner_block)}</div>
    </section>
    """
  end
end
