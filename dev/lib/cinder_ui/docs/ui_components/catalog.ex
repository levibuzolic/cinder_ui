defmodule CinderUI.Docs.UIComponents.Catalog do
  @moduledoc false

  use Phoenix.Component

  import CinderUI.Classes

  alias CinderUI.Components.{Actions, Feedback, Layout, Navigation, Overlay}
  alias CinderUI.Docs.UIComponents.Code
  alias CinderUI.Docs.UIComponents.Shell
  alias CinderUI.Icons

  attr :component_count, :integer, default: nil
  attr :show_count, :boolean, default: false
  attr :rest, :global

  def docs_overview_intro(assigns) do
    ~H"""
    <section class="mb-8" {@rest}>
      <h2 class="text-2xl font-semibold tracking-tight">Component Library</h2>
      <p class="text-muted-foreground mt-2 max-w-3xl text-sm">
        Static docs for Cinder UI components. Open any component for preview, HEEx usage,
        generated attributes/slots docs, and a link to the original shadcn/ui reference.
      </p>
      <p :if={@show_count} class="mt-3 text-sm">
        <span class="text-muted-foreground">Components:</span>
        <span data-testid="component-count" class="font-semibold">{@component_count}</span>
      </p>
    </section>
    """
  end

  attr :sections, :list, default: []
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."
  attr :rest, :global

  def docs_overview_sections(assigns) do
    ~H"""
    <div {@rest}>
      <%= for section <- @sections do %>
        <section id={section.id} class="mb-12">
          <h3 class="mb-4 text-xl font-semibold">{section.title}</h3>
          <div class="grid gap-4 md:grid-cols-2">
            <.docs_overview_entry
              :for={entry <- section.entries}
              entry={entry}
              mode={@mode}
              root_prefix={@root_prefix}
            />
          </div>
        </section>
      <% end %>
    </div>
    """
  end

  attr :entry, :map, required: true
  attr :sections, :list, required: true
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."
  attr :rest, :global

  def docs_component_detail(assigns) do
    assigns =
      assigns
      |> assign(:docs_html, summary_markdown_html(assigns.entry.docs))
      |> assign(:back_section_id, section_id_for_entry(assigns.sections, assigns.entry.id))
      |> assign(:section_title, section_title_for_entry(assigns.sections, assigns.entry.id))
      |> assign(:residual_docs, docs_residual(assigns.entry.docs_full, assigns.entry.docs))

    ~H"""
    <div {@rest}>
      <div class="mb-6 flex flex-wrap items-center justify-between gap-3">
        <Navigation.breadcrumb>
          <Navigation.breadcrumb_list class="text-xs">
            <Navigation.breadcrumb_item>
              <Navigation.breadcrumb_link href={overview_href(@mode, @root_prefix)}>
                Overview
              </Navigation.breadcrumb_link>
            </Navigation.breadcrumb_item>
            <Navigation.breadcrumb_separator />
            <Navigation.breadcrumb_item>
              <Navigation.breadcrumb_link href={
                back_to_index_href(@mode, @root_prefix, @back_section_id)
              }>
                {@section_title}
              </Navigation.breadcrumb_link>
            </Navigation.breadcrumb_item>
          </Navigation.breadcrumb_list>
        </Navigation.breadcrumb>
        <Shell.docs_external_link_button
          href={@entry.shadcn_url}
          variant={:outline}
          size={:xs}
        >
          Original shadcn/ui docs ↗
        </Shell.docs_external_link_button>
      </div>

      <section class="mb-6">
        <div class="mt-1 flex flex-wrap items-center gap-3">
          <h2 class="text-2xl font-semibold tracking-tight">
            <code>{@entry.module_name}.{@entry.title}</code>
          </h2>
          <.docs_runtime_badge runtime={@entry.runtime} />
        </div>
        <div class="docs-markdown mt-3 text-sm">{rendered(@docs_html)}</div>
      </section>

      <section :if={@residual_docs != ""} class="mb-6">
        <div class="docs-markdown space-y-3 text-sm">
          {rendered(summary_markdown_html(@residual_docs))}
        </div>
      </section>

      <section class="mb-8 space-y-4">
        <%= for {example, index} <- Enum.with_index(@entry.examples, 1) do %>
          <section
            class="mb-10"
            data-component-example
            data-component-id={@entry.id}
            data-example-id={example.id}
            data-example-title={example.title}
            data-promoted-visual={example.promoted_visual}
          >
            <header>
              <div class="flex flex-wrap items-center gap-2">
                <h3 class="text-sm font-semibold">
                  {example_heading(example.title, index, length(@entry.examples))}
                </h3>
                <Feedback.badge
                  :if={Map.get(example, :phoenix_shim, false)}
                  color={:info}
                  variant={:outline}
                  class="text-[10px] uppercase tracking-[0.08em]"
                >
                  Phoenix shim
                </Feedback.badge>
              </div>
              <p
                :if={is_binary(example.description) and example.description != ""}
                class="text-muted-foreground mt-1 text-xs"
              >
                {example.description}
              </p>
            </header>

            <.docs_example_card
              preview_html={example.preview_html}
              template_heex={example.template_heex}
              copy_id={"#{@entry.id}-#{example.id}"}
              code_id={"code-#{@entry.id}-#{example.id}"}
              preview_align={example.preview_align || :center}
              class="mt-4"
            />
          </section>
        <% end %>
      </section>
    </div>

    <section class="mb-6">
      <h3 class="mb-3 text-sm font-semibold">Attributes</h3>

      <%= if @entry.attributes == [] do %>
        <p class="text-sm text-muted-foreground">No attributes declared.</p>
      <% else %>
        <div class="overflow-auto rounded-md border">
          <table class="w-full min-w-[680px] text-left text-xs">
            <thead class="bg-muted/40">
              <tr>
                <th class="px-3 py-2 font-medium">Name</th>
                <th class="px-3 py-2 font-medium">Type</th>
                <th class="px-3 py-2 font-medium">Default</th>
                <th class="px-3 py-2 font-medium">Values</th>
                <th class="px-3 py-2 font-medium">Global Includes</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={attr <- @entry.attributes} class="border-border/60 border-t align-top">
                <td class="px-3 py-2">
                  <code>{attr.name}</code>
                  <.required_badge :if={attr.required} class="ml-2" />
                </td>
                <td class="px-3 py-2"><code>{attr.type}</code></td>
                <td class="px-3 py-2">
                  <%= if is_nil(attr.default) do %>
                    —
                  <% else %>
                    <code>{inspect(attr.default)}</code>
                  <% end %>
                </td>
                <td class="px-3 py-2">
                  <%= if attr.values == [] do %>
                    —
                  <% else %>
                    <%= for {value, idx} <- Enum.with_index(attr.values) do %>
                      <%= if idx > 0 do %>
                        ,
                      <% end %>
                      <code>{inspect(value)}</code>
                    <% end %>
                  <% end %>
                </td>
                <td class="px-3 py-2">
                  <%= if attr.includes == [] do %>
                    —
                  <% else %>
                    <%= for {include, idx} <- Enum.with_index(attr.includes) do %>
                      <%= if idx > 0 do %>
                        ,
                      <% end %>
                      <code>{include}</code>
                    <% end %>
                  <% end %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      <% end %>
    </section>

    <section class="mb-6">
      <h3 class="mb-3 text-sm font-semibold">Slots</h3>

      <%= if @entry.slots == [] do %>
        <p class="text-sm text-muted-foreground">No slots declared.</p>
      <% else %>
        <div class="overflow-auto rounded-md border">
          <table class="w-full min-w-[560px] text-left text-xs">
            <thead class="bg-muted/40">
              <tr>
                <th class="px-3 py-2 font-medium">Slot</th>
                <th class="px-3 py-2 font-medium">Slot Attributes</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={slot <- @entry.slots} class="border-border/60 border-t align-top">
                <td class="px-3 py-2">
                  <code>{slot.name}</code>
                  <.required_badge :if={slot.required} class="ml-2" />
                </td>
                <td class="px-3 py-2">
                  <%= if slot.attrs == [] do %>
                    —
                  <% else %>
                    <div :for={attr <- slot.attrs} class="leading-5">
                      <code>{attr.name}</code>
                      <span class="text-muted-foreground">({attr.type})</span>
                      <.required_badge :if={attr.required} class="ml-1" />
                    </div>
                  <% end %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      <% end %>
    </section>
    """
  end

  attr :entry, :map, required: true
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."

  defp docs_overview_entry(assigns) do
    assigns =
      assigns
      |> assign(:docs_html, summary_markdown_html(assigns.entry.docs))
      |> assign(:preview_align, assigns.entry.preview_align || :center)
      |> assign(
        :entry_href,
        overview_entry_href(assigns.mode, assigns.root_prefix, assigns.entry)
      )

    ~H"""
    <article
      id={@entry.id}
      data-component-card
      data-component-name={@entry.title}
    >
      <Layout.panel class="h-full divide-y">
        <div class="p-4">
          <div class="flex flex-wrap items-start justify-between gap-2">
            <h4 class="font-medium">
              <a href={@entry_href} class="underline-offset-4 hover:underline">
                <code>{@entry.module_name}.{@entry.title}</code>
              </a>
            </h4>
            <div class="flex items-center gap-2">
              <.docs_runtime_badge runtime={@entry.runtime} />
              <Actions.button as="a" href={@entry_href} variant={:outline} size={:xs}>
                Open docs
              </Actions.button>
            </div>
          </div>
          <div class="docs-markdown text-sm">{rendered(@docs_html)}</div>
        </div>

        <.docs_example_card
          preview_html={@entry.preview_html}
          template_heex={@entry.template_heex}
          copy_id={@entry.id}
          code_id={"code-#{@entry.id}"}
          preview_align={@preview_align}
          compact
        />
      </Layout.panel>
    </article>
    """
  end

  attr :preview_html, :string, required: true
  attr :template_heex, :string, required: true
  attr :copy_id, :string, required: true
  attr :code_id, :string, required: true
  attr :preview_align, :atom, default: :center
  attr :compact, :boolean, default: false
  attr :class, :string, default: nil

  defp docs_example_card(%{compact: true} = assigns) do
    ~H"""
    <div
      data-slot="preview"
      data-preview-align={@preview_align}
      class={
        classes([
          "bg-background min-h-[7rem] flex-1 p-4",
          @preview_align == :center && "flex items-center justify-center"
        ])
      }
    >
      {rendered(@preview_html)}
    </div>

    <.docs_example_code
      copy_id={@copy_id}
      code_id={@code_id}
      template_heex={@template_heex}
      compact
    />
    """
  end

  defp docs_example_card(assigns) do
    ~H"""
    <div class={classes(["rounded-xl border divide-y", @class])}>
      <div
        data-slot="preview"
        data-preview-align={@preview_align}
        class={
          classes([
            "p-4 sm:p-6",
            @preview_align == :center && "flex items-center justify-center"
          ])
        }
      >
        {rendered(@preview_html)}
      </div>

      <.docs_example_code
        copy_id={@copy_id}
        code_id={@code_id}
        template_heex={@template_heex}
      />
    </div>
    """
  end

  attr :copy_id, :string, required: true
  attr :code_id, :string, required: true
  attr :template_heex, :string, required: true
  attr :compact, :boolean, default: false

  defp docs_example_code(assigns) do
    ~H"""
    <div data-slot="code" class="relative min-w-0">
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
        source={@template_heex}
        language={:heex}
        pre_class={
          classes([
            "m-0 min-w-0 max-w-full overflow-x-auto leading-4",
            if(@compact, do: "pr-12", else: "bg-muted/30")
          ])
        }
      />
    </div>
    """
  end

  attr :class, :string, default: nil

  defp required_badge(assigns) do
    ~H"""
    <Feedback.badge color={:destructive} class={classes(["align-middle", @class])}>
      Required
    </Feedback.badge>
    """
  end

  attr :runtime, :map, required: true

  defp docs_runtime_badge(assigns) do
    assigns =
      assigns
      |> assign(:dot_class, runtime_dot_class(assigns.runtime.kind))
      |> assign(:badge_class, runtime_badge_class(assigns.runtime.kind))

    ~H"""
    <Overlay.tooltip
      text={@runtime.summary}
      data-component-runtime
      data-runtime-kind={@runtime.kind}
    >
      <Feedback.badge variant={:outline} class={@badge_class}>
        {@runtime.label}
      </Feedback.badge>
    </Overlay.tooltip>
    """
  end

  defp section_id_for_entry(sections, entry_id) do
    Enum.find_value(sections, "actions", fn section ->
      if Enum.any?(section.entries, &(&1.id == entry_id)), do: section.id
    end)
  end

  defp section_title_for_entry(sections, entry_id) do
    Enum.find_value(sections, "Actions", fn section ->
      if Enum.any?(section.entries, &(&1.id == entry_id)), do: section.title
    end)
  end

  defp example_heading("Default", 1, 1), do: "Example"
  defp example_heading(title, _index, _total), do: title

  defp docs_residual(doc, summary) do
    doc
    |> String.trim()
    |> maybe_strip_leading_summary(summary)
    |> strip_markdown_sections(
      ~w(example examples attribute attributes slot slots usage variant variants screenshot screenshots)
    )
    |> String.trim()
  end

  defp maybe_strip_leading_summary(doc, summary) when is_binary(summary) and summary != "" do
    String.replace(doc, ~r/\A#{Regex.escape(summary)}\s*\n*/u, "")
  end

  defp maybe_strip_leading_summary(doc, _summary), do: doc

  defp strip_markdown_sections(doc, headings) do
    heading_set = MapSet.new(headings)

    {lines, _skip_level} =
      doc
      |> String.split("\n")
      |> Enum.reduce({[], nil}, fn line, {lines, skip_level} ->
        case heading_metadata(String.trim_leading(line)) do
          {:heading, level, title} ->
            if MapSet.member?(heading_set, normalize_heading_title(title)) do
              {lines, level}
            else
              if is_integer(skip_level) and level > skip_level do
                {lines, skip_level}
              else
                {[line | lines], nil}
              end
            end

          :not_heading ->
            if is_integer(skip_level), do: {lines, skip_level}, else: {[line | lines], nil}
        end
      end)

    lines
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp heading_metadata(line) do
    case Regex.run(~r/^(#+)\s+(.+?)\s*$/, line, capture: :all_but_first) do
      [hashes, title] -> {:heading, String.length(hashes), String.trim(title)}
      _ -> :not_heading
    end
  end

  defp normalize_heading_title(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.trim()
  end

  defp summary_markdown_html(text), do: Code.summary_markdown_html(text)

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp overview_href(:static, root_prefix), do: "#{root_prefix}/"
  defp overview_href(:live, _root_prefix), do: "/docs"

  defp overview_entry_href(:static, root_prefix, entry),
    do: "#{root_prefix}/#{String.replace_suffix(entry.docs_path, "/index.html", "/")}"

  defp overview_entry_href(:live, _root_prefix, entry), do: "/docs/#{entry.id}/"

  defp back_to_index_href(:static, root_prefix, section_id), do: "#{root_prefix}/##{section_id}"
  defp back_to_index_href(:live, _root_prefix, section_id), do: "/docs/##{section_id}"

  defp runtime_badge_class(:server) do
    "h-6 gap-1.5 px-2.5 leading-none border-emerald-200 bg-emerald-50/80 text-emerald-700 dark:border-emerald-900/70 dark:bg-emerald-950/40 dark:text-emerald-300"
  end

  defp runtime_badge_class(:progressive) do
    "h-6 gap-1.5 px-2.5 leading-none border-sky-200 bg-sky-50/80 text-sky-700 dark:border-sky-900/70 dark:bg-sky-950/40 dark:text-sky-300"
  end

  defp runtime_badge_class(:scaffold) do
    "h-6 gap-1.5 px-2.5 leading-none border-amber-200 bg-amber-50/80 text-amber-700 dark:border-amber-900/70 dark:bg-amber-950/40 dark:text-amber-300"
  end

  defp runtime_dot_class(:server), do: "size-1.5 rounded-full bg-current"

  defp runtime_dot_class(:progressive) do
    "size-1.5 rounded-full bg-current shadow-[0_0_0_3px_rgba(14,165,233,0.14)] dark:shadow-[0_0_0_3px_rgba(56,189,248,0.18)]"
  end

  defp runtime_dot_class(:scaffold) do
    "size-1.5 rounded-full bg-current shadow-[0_0_0_3px_rgba(245,158,11,0.14)] dark:shadow-[0_0_0_3px_rgba(251,191,36,0.18)]"
  end
end
