defmodule CinderUI.Docs.UIComponents do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Components.{Actions, Feedback, Forms, Layout, Navigation}
  alias CinderUI.Docs.CodeHighlighter
  alias CinderUI.Icons
  alias Phoenix.HTML

  attr :href, :string, required: true
  attr :variant, :atom, default: :outline
  attr :size, :atom, default: :sm
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def docs_external_link_button(assigns) do
    ~H"""
    <Actions.button
      as="a"
      href={@href}
      target="_blank"
      rel="noopener noreferrer"
      variant={@variant}
      size={@size}
      class={@class}
    >
      {render_slot(@inner_block)}
    </Actions.button>
    """
  end

  attr :sections, :list, default: []
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."
  attr :active_entry_id, :string, default: nil
  attr :active_page, :atom, default: nil

  attr :home_url, :string, default: nil
  attr :github_url, :string, default: nil
  attr :hex_package_url, :string, default: nil

  slot :inner_block, required: true

  def docs_layout(assigns) do
    ~H"""
    <div class="mx-auto grid min-h-screen max-w-[1900px] grid-cols-1 lg:grid-cols-[320px_minmax(0,1fr)]">
      <aside
        data-docs-sidebar
        data-scroll-restored="false"
        class="border-border/70 sticky top-0 h-screen overflow-y-auto border-r px-5 py-6"
        style="visibility: hidden;"
      >
        <div class="mb-6">
          <h1 class="text-xl font-semibold">
            <%= if is_binary(@home_url) and @home_url != "" do %>
              <a href={@home_url}>Cinder UI</a>
            <% else %>
              Cinder UI
            <% end %>
          </h1>
          <p class="text-muted-foreground mt-1 text-sm">Static component docs</p>
          <.docs_header_links github_url={@github_url} hex_package_url={@hex_package_url} />
        </div>

        <.docs_theme_controls />

        <.docs_search_button />

        <nav class="space-y-4" aria-label="Component sections">
          <.docs_sidebar
            sections={@sections}
            mode={@mode}
            root_prefix={@root_prefix}
            active_entry_id={@active_entry_id}
            active_page={@active_page}
          />
        </nav>
        <script>
          (() => {
            const sidebar = document.currentScript?.closest("[data-docs-sidebar]");
            if (!sidebar) return;

            try {
              const key = "cui:docs:sidebar-scroll-top";
              const saved = Number.parseInt(sessionStorage.getItem(key) || "", 10);
              if (Number.isFinite(saved) && saved >= 0) sidebar.scrollTop = saved;
            } catch (_error) {}

            sidebar.dataset.scrollRestored = "true";
            sidebar.style.removeProperty("visibility");
          })();
        </script>
      </aside>

      <main class="min-w-0 px-5 py-6 lg:px-8">
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  attr :github_url, :string, default: nil
  attr :hex_package_url, :string, default: nil

  def docs_header_links(assigns) do
    ~H"""
    <div
      :if={
        (is_binary(@github_url) and @github_url != "") or
          (is_binary(@hex_package_url) and @hex_package_url != "")
      }
      class="mt-3 flex flex-wrap gap-1 text-xs"
    >
      <.docs_external_link_button
        :if={is_binary(@github_url) and @github_url != ""}
        href={@github_url}
        variant={:outline}
        size={:xs}
      >
        GitHub
      </.docs_external_link_button>
      <.docs_external_link_button
        :if={is_binary(@hex_package_url) and @hex_package_url != ""}
        href={@hex_package_url}
        variant={:outline}
        size={:xs}
      >
        Hex package
      </.docs_external_link_button>
    </div>
    """
  end

  def docs_sidebar(assigns) do
    ~H"""
    <div>
      <a
        href={install_href(@mode, @root_prefix)}
        class={sidebar_link_class(@active_page == :install)}
        aria-current={if @active_page == :install, do: "page", else: nil}
      >
        Installation
      </a>
    </div>

    <div>
      <a
        href={overview_href(@mode, @root_prefix)}
        class={sidebar_link_class(@active_page == :overview)}
        aria-current={if @active_page == :overview, do: "page", else: nil}
      >
        Overview
      </a>
    </div>

    <%= for section <- @sections do %>
      <div>
        <a
          href={section_href(@mode, @root_prefix, section.id)}
          class="sidebar-section-link text-sm font-semibold"
        >
          {section.title}
        </a>
        <ul class="mt-2 space-y-1">
          <li :for={entry <- section.entries}>
            <a
              class={sidebar_link_class(entry.id == @active_entry_id)}
              href={entry_href(@mode, @root_prefix, entry)}
              aria-current={if entry.id == @active_entry_id, do: "page", else: nil}
            >
              {entry.title}
            </a>
          </li>
        </ul>
      </div>
    <% end %>
    """
  end

  def docs_theme_controls(assigns) do
    assigns =
      assigns
      |> assign(:color_options, color_options())
      |> assign(:radius_options, radius_options())

    ~H"""
    <section class="mb-6 rounded-lg border p-3">
      <Navigation.tabs value="auto" class="w-full gap-0 [&_[data-slot=tabs-list]]:w-full">
        <:trigger value="light" data_theme_mode="light" class="theme-mode-btn">Light</:trigger>
        <:trigger value="dark" data_theme_mode="dark" class="theme-mode-btn">Dark</:trigger>
        <:trigger value="auto" data_theme_mode="auto" class="theme-mode-btn">Auto</:trigger>
      </Navigation.tabs>

      <div class="mt-3">
        <Forms.label for="theme-color" class="mb-1 block text-xs font-medium text-muted-foreground">
          Base color
        </Forms.label>
        <p class="mb-2 text-[11px] text-muted-foreground">
          Matches shadcn <code>tailwind.baseColor</code>.
        </p>
        <Forms.select
          name="theme-color"
          value="neutral"
          id="theme-color"
          aria-label="Theme color"
        >
          <:option :for={option <- @color_options} value={option.value} label={option.label} />
        </Forms.select>
      </div>

      <div class="mt-3">
        <Forms.label for="theme-radius" class="mb-2 block text-xs font-medium text-muted-foreground">
          Radius
        </Forms.label>
        <Forms.select
          name="theme-radius"
          value="nova"
          id="theme-radius"
          aria-label="Theme radius"
        >
          <:option :for={option <- @radius_options} value={option.value} label={option.label} />
        </Forms.select>
      </div>
    </section>
    """
  end

  def docs_search_button(assigns) do
    ~H"""
    <div class="mb-5">
      <Actions.button
        type="button"
        variant={:outline}
        data-open-command-palette
        class="w-full justify-between px-3 py-2 text-sm"
      >
        <span>Search components</span>
        <span class="text-muted-foreground text-xs">⌘K / Ctrl+K</span>
      </Actions.button>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :source, :string, required: true
  attr :language, :atom, default: :auto
  attr :pre_class, :any, default: nil
  attr :code_class, :any, default: nil

  def docs_code_block(assigns) do
    assigns =
      assigns
      |> assign(:highlighted_html, highlighted_code_html(assigns.source, assigns.language))
      |> assign(
        :pre_classes,
        List.wrap(assigns.pre_class)
      )
      |> assign(
        :code_classes,
        ["code-highlight block min-w-max whitespace-pre" | List.wrap(assigns.code_class)]
      )

    ~H"""
    <pre class={@pre_classes}>
      <code id={@id} class={@code_classes}><%= rendered(@highlighted_html) %></code>
    </pre>
    """
  end

  attr :component_count, :integer, default: nil
  attr :show_count, :boolean, default: false

  def docs_overview_intro(assigns) do
    ~H"""
    <section class="mb-8">
      <h2 class="text-2xl font-semibold tracking-tight">Component Library</h2>
      <p class="text-muted-foreground mt-2 max-w-3xl text-sm">
        Static docs for Cinder UI components. Open any component for preview, HEEx usage,
        generated attributes/slots docs, and a link to the original shadcn/ui reference.
      </p>
      <p :if={@show_count} class="text-sm mt-3">
        <span class="text-muted-foreground">Components:</span>
        <span data-testid="component-count" class="font-semibold">{@component_count}</span>
      </p>
    </section>
    """
  end

  attr :sections, :list, default: []
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."

  def docs_overview_sections(assigns) do
    ~H"""
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
    """
  end

  attr :entry, :map, required: true
  attr :sections, :list, required: true
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."

  def docs_component_detail(assigns) do
    assigns =
      assigns
      |> assign(:docs_html, summary_markdown_html(assigns.entry.docs))
      |> assign(:back_section_id, section_id_for_entry(assigns.sections, assigns.entry.id))
      |> assign(:residual_docs, docs_residual(assigns.entry.docs_full, assigns.entry.docs))

    ~H"""
    <div class="mb-6 flex flex-wrap items-center justify-between gap-3">
      <Actions.button
        as="a"
        href={back_to_index_href(@mode, @root_prefix, @back_section_id)}
        variant={:outline}
        size={:xs}
      >
        <Icons.icon name="arrow-left" class="size-3.5" /> Back to index
      </Actions.button>
      <.docs_external_link_button
        href={@entry.shadcn_url}
        variant={:outline}
        size={:xs}
      >
        Original shadcn/ui docs ↗
      </.docs_external_link_button>
    </div>

    <section class="mb-6">
      <p class="text-muted-foreground text-xs">{@entry.module_name}</p>
      <h2 class="mt-1 text-2xl font-semibold tracking-tight">
        <code>{@entry.module_name}.{@entry.title}</code>
      </h2>
      <div class="mt-3">
        <.docs_runtime_badge runtime={@entry.runtime} show_summary />
      </div>
      <div class="docs-markdown mt-3 text-sm">{rendered(@docs_html)}</div>
    </section>

    <section :if={@residual_docs != ""} class="mb-6">
      <div class="space-y-3 text-sm docs-markdown">
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
            <h3 class="text-sm font-semibold">
              {example_heading(example.title, index, length(@entry.examples))}
            </h3>
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
            <div class="space-y-2">
              <h4 class="font-medium">
                <a href={@entry_href} class="hover:underline underline-offset-4">
                  <code>{@entry.module_name}.{@entry.title}</code>
                </a>
              </h4>
              <.docs_runtime_badge runtime={@entry.runtime} />
            </div>
            <div class="flex items-center gap-1">
              <Actions.button
                as="a"
                href={@entry_href}
                variant={:outline}
                size={:xs}
              >
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

  defp color_options do
    Enum.map(["gray", "neutral", "slate", "stone", "zinc"], fn option ->
      %{value: option, label: option |> String.replace("_", " ") |> String.capitalize()}
    end)
  end

  defp radius_options do
    Enum.map(
      [
        {"maia", "Compact (6px / 0.375rem)"},
        {"mira", "Small (8px / 0.5rem)"},
        {"nova", "Default (12px / 0.75rem)"},
        {"lyra", "Large (14px / 0.875rem)"},
        {"vega", "XL (16px / 1rem)"}
      ],
      fn {value, label} -> %{value: value, label: label} end
    )
  end

  defp overview_href(:static, root_prefix), do: "#{root_prefix}/"
  defp overview_href(:live, _root_prefix), do: "/docs"

  defp install_href(:static, root_prefix), do: "#{root_prefix}/install/"
  defp install_href(:live, _root_prefix), do: "/docs/install/"

  defp section_href(:static, root_prefix, section_id), do: "#{root_prefix}/##{section_id}"
  defp section_href(:live, _root_prefix, section_id), do: "/docs/##{section_id}"

  defp entry_href(:static, root_prefix, entry),
    do: "#{root_prefix}/#{pretty_docs_path(entry.docs_path)}"

  defp entry_href(:live, _root_prefix, entry), do: "/docs/#{entry.id}/"

  defp overview_entry_href(:static, root_prefix, entry),
    do: "#{root_prefix}/#{pretty_docs_path(entry.docs_path)}"

  defp overview_entry_href(:live, _root_prefix, entry), do: "/docs/#{entry.id}/"

  defp back_to_index_href(:static, root_prefix, section_id), do: "#{root_prefix}/##{section_id}"
  defp back_to_index_href(:live, _root_prefix, section_id), do: "/docs/##{section_id}"

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
      class={[
        "bg-background min-h-[7rem] flex-1 p-4",
        @preview_align == :center && "flex items-center justify-center"
      ]}
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
    <div class={["rounded-xl border", @class]}>
      <div
        data-slot="preview"
        data-preview-align={@preview_align}
        class={[
          "p-4 sm:p-6",
          @preview_align == :center && "flex items-center justify-center"
        ]}
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
    <div data-slot="code" class="relative min-w-0 border-t">
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
      <.docs_code_block
        id={@code_id}
        source={@template_heex}
        language={:heex}
        pre_class={[
          "m-0 min-w-0 max-w-full overflow-x-auto overflow-y-auto p-4 text-xs leading-4",
          if(@compact, do: "max-h-56 pr-12", else: "max-h-96 bg-muted/30")
        ]}
      />
    </div>
    """
  end

  attr :class, :string, default: nil

  defp required_badge(assigns) do
    ~H"""
    <Feedback.badge variant={:destructive} class={"align-middle #{@class}"}>Required</Feedback.badge>
    """
  end

  attr :runtime, :map, required: true
  attr :show_summary, :boolean, default: false

  defp docs_runtime_badge(assigns) do
    assigns =
      assigns
      |> assign(:dot_class, runtime_dot_class(assigns.runtime.kind))
      |> assign(:badge_class, runtime_badge_class(assigns.runtime.kind))

    ~H"""
    <div
      data-component-runtime
      data-runtime-kind={@runtime.kind}
      class="flex flex-wrap items-center gap-2"
    >
      <Feedback.badge variant={:outline} class={@badge_class}>
        <span aria-hidden="true" class={@dot_class} />
        {@runtime.label}
      </Feedback.badge>
      <p :if={@show_summary} class="text-muted-foreground text-xs">
        {@runtime.summary}
      </p>
    </div>
    """
  end

  defp section_id_for_entry(sections, entry_id) do
    Enum.find_value(sections, "actions", fn section ->
      if Enum.any?(section.entries, &(&1.id == entry_id)), do: section.id
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
    Enum.reduce(headings, doc, fn heading, acc ->
      pattern = ~r/(?:^|\n)##+\s+#{heading}\b[\s\S]*?(?=\n##+\s|\z)/mi
      String.replace(acc, pattern, "\n")
    end)
  end

  defp sidebar_link_class(active?) do
    base = "sidebar-link block rounded-md px-2 py-1.5 text-sm transition-colors"

    if active? do
      "#{base} bg-accent text-accent-foreground font-medium"
    else
      "#{base} text-muted-foreground hover:bg-accent/50 hover:text-foreground"
    end
  end

  defp pretty_docs_path(path) do
    String.replace_suffix(path, "/index.html", "/")
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp highlighted_code_html(source, language) do
    CodeHighlighter.highlight(source, language)
  end

  defp summary_markdown_html(text) do
    case Earmark.as_html(text, compact_output: true) do
      {:ok, html, _messages} -> html
      {:error, html, _messages} -> html
    end
  rescue
    _ ->
      "<p>#{escape(text)}</p>"
  end

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()

  defp runtime_badge_class(:server) do
    "gap-1.5 border-emerald-200 bg-emerald-50/80 text-emerald-700 dark:border-emerald-900/70 dark:bg-emerald-950/40 dark:text-emerald-300"
  end

  defp runtime_badge_class(:progressive) do
    "gap-1.5 border-sky-200 bg-sky-50/80 text-sky-700 dark:border-sky-900/70 dark:bg-sky-950/40 dark:text-sky-300"
  end

  defp runtime_badge_class(:scaffold) do
    "gap-1.5 border-amber-200 bg-amber-50/80 text-amber-700 dark:border-amber-900/70 dark:bg-amber-950/40 dark:text-amber-300"
  end

  defp runtime_dot_class(:server) do
    "size-1.5 rounded-full bg-current"
  end

  defp runtime_dot_class(:progressive) do
    "size-1.5 rounded-full bg-current shadow-[0_0_0_3px_rgba(14,165,233,0.14)] dark:shadow-[0_0_0_3px_rgba(56,189,248,0.18)]"
  end

  defp runtime_dot_class(:scaffold) do
    "size-1.5 rounded-full bg-current shadow-[0_0_0_3px_rgba(245,158,11,0.14)] dark:shadow-[0_0_0_3px_rgba(251,191,36,0.18)]"
  end
end
