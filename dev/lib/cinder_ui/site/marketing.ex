defmodule CinderUI.Site.Marketing do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Components.Actions
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Docs.UIComponents, as: Docs
  alias CinderUI.Icons
  alias Phoenix.HTML.Safe

  @template_dir Path.expand("../../../../priv/site_templates", __DIR__)

  def write_marketing_index!(output_dir, opts \\ %{}) do
    project = Mix.Project.config()
    github_url = Map.get(opts, :github_url, to_string(project[:source_url] || ""))
    hex_url = Map.get(opts, :hex_url, "https://hex.pm/packages/cinder_ui")
    hexdocs_url = Map.get(opts, :hexdocs_url, "https://hexdocs.pm/cinder_ui")
    version = Map.get(opts, :version, to_string(project[:version] || "0.0.0"))
    component_count = Map.get(opts, :component_count, 0)
    docs_path = Map.get(opts, :docs_path, "./docs/")
    theme_css_path = Map.get(opts, :theme_css_path, "./docs/assets/theme.css")
    site_css_path = Map.get(opts, :site_css_path, "./assets/site.css")

    theme_script_src =
      Map.get(opts, :theme_script_src, Path.join(docs_path, "assets/static_docs.js"))

    File.mkdir_p!(output_dir)

    File.write!(
      Path.join(output_dir, "index.html"),
      index_html(
        version,
        component_count,
        github_url,
        hex_url,
        hexdocs_url,
        theme_css_path,
        docs_path,
        site_css_path,
        theme_script_src
      )
    )

    File.write!(Path.join(output_dir, ".nojekyll"), "")
  end

  def render_marketing_html(opts \\ %{}) do
    project = Mix.Project.config()
    github_url = Map.get(opts, :github_url, to_string(project[:source_url] || ""))
    hex_url = Map.get(opts, :hex_url, "https://hex.pm/packages/cinder_ui")
    hexdocs_url = Map.get(opts, :hexdocs_url, "https://hexdocs.pm/cinder_ui")
    version = Map.get(opts, :version, to_string(project[:version] || "0.0.0"))
    component_count = Map.get(opts, :component_count, 0)
    docs_path = Map.get(opts, :docs_path, "./docs/")
    theme_css_path = Map.get(opts, :theme_css_path, "./docs/assets/theme.css")
    site_css_path = Map.get(opts, :site_css_path, "./assets/site.css")

    theme_script_src =
      Map.get(opts, :theme_script_src, Path.join(docs_path, "assets/static_docs.js"))

    index_html(
      version,
      component_count,
      github_url,
      hex_url,
      hexdocs_url,
      theme_css_path,
      docs_path,
      site_css_path,
      theme_script_src
    )
  end

  defp index_html(
         version,
         component_count,
         github_url,
         hex_url,
         hexdocs_url,
         theme_css_path,
         docs_path,
         site_css_path,
         theme_script_src
       ) do
    shadcn_url = "https://ui.shadcn.com/docs"

    assigns = [
      theme_bootstrap_script: theme_bootstrap_script(),
      theme_css_path: theme_css_path,
      site_css_path: site_css_path,
      header_controls_html: header_controls_html(docs_path, github_url, hex_url, hexdocs_url),
      shadcn_url: shadcn_url,
      hero_html: hero_html(version, component_count, shadcn_url, docs_path),
      signal_strip_html: signal_strip_html(version, component_count),
      component_examples_html: component_examples_html(shadcn_url),
      install_html: install_html(version, docs_path),
      theme_tokens_html: theme_tokens_html(),
      features_html: features_html(shadcn_url),
      theme_script_src: theme_script_src
    ]

    "index.html.eex"
    |> template!()
    |> EEx.eval_string(assigns)
  end

  defp header_controls_html(docs_path, github_url, hex_url, hexdocs_url) do
    assigns = %{
      docs_path: docs_path,
      github_url: github_url,
      hex_url: hex_url,
      hexdocs_url: hexdocs_url
    }

    ~H"""
    <div class="site-header-links flex flex-wrap items-center gap-2 md:justify-end">
      <a href={@docs_path} class="site-header-link">Docs</a>
      <Docs.docs_external_link_button
        :if={is_binary(@github_url) and @github_url != ""}
        href={@github_url}
        variant={:outline}
        size={:sm}
      >
        GitHub
      </Docs.docs_external_link_button>
      <Docs.docs_external_link_button
        :if={is_binary(@hex_url) and @hex_url != ""}
        href={@hex_url}
        variant={:outline}
        size={:sm}
      >
        Hex
      </Docs.docs_external_link_button>
      <Docs.docs_external_link_button
        :if={is_binary(@hexdocs_url) and @hexdocs_url != ""}
        href={@hexdocs_url}
        variant={:outline}
        size={:sm}
      >
        HexDocs
      </Docs.docs_external_link_button>

      <Docs.theme_mode_toggle class="site-theme-toggle" />
    </div>
    """
    |> to_html()
  end

  defp hero_html(version, component_count, shadcn_url, docs_path) do
    assigns = %{
      version: version,
      component_count: component_count,
      shadcn_url: shadcn_url,
      docs_path: docs_path,
      install_docs_path: Path.join(docs_path, "install/"),
      hero_preview_html: hero_preview_html()
    }

    ~H"""
    <section class="site-hero-section">
      <div class="site-eyebrow-row">
        <Feedback.badge variant={:outline} class="site-eyebrow-badge">
          <Icons.icon name="sparkles" class="size-3" />
          Phoenix-first UI system
        </Feedback.badge>
        <p class="site-eyebrow-copy">
          Styled like a polished product launch, backed by server-rendered primitives.
        </p>
      </div>

      <div class="site-hero-grid">
        <div class="site-hero-copy">
          <div class="space-y-4">
            <h1 class="site-hero-title">
              <span>Professional</span>
              <span>LiveView interfaces</span>
              <span class="site-hero-title-muted">without rebuilding the design system from scratch.</span>
            </h1>
            <p class="site-hero-body">
              Cinder UI brings
              <a
                href={@shadcn_url}
                target="_blank"
                rel="noopener noreferrer"
                class="underline underline-offset-4"
              >
                shadcn/ui
              </a>
              patterns into Phoenix with typed HEEx APIs, installer automation, and progressive enhancement where it actually helps.
            </p>
          </div>

          <div class="site-hero-actions">
            <Actions.button as="a" href={@docs_path}>
              Browse Component Library
            </Actions.button>
            <Actions.button as="a" variant={:outline} href={@install_docs_path}>
              Installation Guide
            </Actions.button>
            <Actions.button as="a" variant={:outline} href="#install">
              Quick Start
            </Actions.button>
          </div>

          <div class="site-proof-grid">
            <Layout.card class="site-proof-card">
              <Layout.card_content class="site-proof-content">
                <p class="site-proof-label">Release</p>
                <p class="site-proof-value"><code>v{@version}</code></p>
              </Layout.card_content>
            </Layout.card>

            <Layout.card class="site-proof-card">
              <Layout.card_content class="site-proof-content">
                <p class="site-proof-label">Components</p>
                <p class="site-proof-value"><code>{@component_count}</code></p>
              </Layout.card_content>
            </Layout.card>

            <Layout.card class="site-proof-card">
              <Layout.card_content class="site-proof-content">
                <p class="site-proof-label">Model</p>
                <p class="site-proof-value">Server-rendered first</p>
              </Layout.card_content>
            </Layout.card>
          </div>
        </div>

        <div class="site-hero-stage">
          {rendered(@hero_preview_html)}
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp hero_preview_html do
    assigns = %{}

    ~H"""
    <Layout.card class="site-stage-card">
      <Layout.card_header class="site-stage-header border-b">
        <div class="site-stage-kicker">
          <Feedback.badge variant={:secondary}>Live preview</Feedback.badge>
          <Feedback.badge variant={:outline}>Cinder UI primitives</Feedback.badge>
        </div>
        <Layout.card_title class="site-stage-title">Shipping panel</Layout.card_title>
        <Layout.card_description class="site-stage-description">
          A tighter example of what the library looks like in a production-feeling screen.
        </Layout.card_description>
      </Layout.card_header>

      <Layout.card_content class="space-y-4">
        <Feedback.alert variant={:success}>
          <Icons.icon name="circle-check-big" class="size-4" />
          <Feedback.alert_title>Deploy ready</Feedback.alert_title>
          <Feedback.alert_description>
            Tests passed, assets built, and theme tokens are aligned across docs and app.
          </Feedback.alert_description>
        </Feedback.alert>

        <Navigation.tabs value="composer">
          <:trigger value="composer">Composer</:trigger>
          <:trigger value="review">Review</:trigger>
          <:content value="composer">
            <div class="space-y-3 py-1">
              <Forms.field>
                <:label>
                  <Forms.label for="site-project">Project name</Forms.label>
                </:label>
                <Forms.input id="site-project" value="Cinder UI" />
                <:description>Typed fields, labels, and help text ship together.</:description>
              </Forms.field>

              <div class="flex items-center justify-between gap-3 rounded-lg border border-border/70 bg-muted/30 px-3 py-2">
                <div>
                  <p class="text-sm font-medium">Progressive enhancement</p>
                  <p class="text-xs text-muted-foreground">Add hooks only where richer behavior pays for itself.</p>
                </div>
                <Forms.switch id="site-progressive" checked={true} />
              </div>
            </div>
          </:content>
          <:content value="review">
            <div class="space-y-3 py-1">
              <div class="grid gap-3 sm:grid-cols-2">
                <div class="rounded-lg border border-border/70 bg-muted/30 p-3">
                  <p class="text-xs uppercase tracking-[0.24em] text-muted-foreground">Surface</p>
                  <p class="mt-2 text-sm font-medium">Docs, demo, and package stay aligned</p>
                </div>
                <div class="rounded-lg border border-border/70 bg-muted/30 p-3">
                  <p class="text-xs uppercase tracking-[0.24em] text-muted-foreground">Confidence</p>
                  <p class="mt-2 text-sm font-medium">Unit, browser, and snapshot checks back the system</p>
                </div>
              </div>
              <Actions.button_group class="w-full">
                <Actions.button class="flex-1">Review components</Actions.button>
                <Actions.button variant={:outline} class="flex-1">Inspect install flow</Actions.button>
              </Actions.button_group>
            </div>
          </:content>
        </Navigation.tabs>
      </Layout.card_content>
    </Layout.card>
    """
    |> to_html()
  end

  defp signal_strip_html(version, component_count) do
    assigns = %{
      items: [
        %{label: "Release", value: "v#{version}"},
        %{label: "Components", value: Integer.to_string(component_count)},
        %{label: "Philosophy", value: "Server first, progressive where needed"},
        %{label: "Install", value: "One command for CSS, hooks, and theme wiring"}
      ]
    }

    ~H"""
    <section class="site-signal-strip" aria-label="Project highlights">
      <div class="site-signal-grid">
        <div :for={item <- @items} class="site-signal-item">
          <p class="site-signal-label">{item.label}</p>
          <p class="site-signal-value">{item.value}</p>
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp component_examples_html(shadcn_url) do
    assigns = %{
      cards: [
        button_group_example_card(shadcn_url),
        form_example_card(shadcn_url),
        alert_example_card(shadcn_url),
        tabs_example_card(shadcn_url)
      ]
    }

    ~H"""
    <section id="examples" class="site-section space-y-6">
      <div class="site-section-heading">
        <div>
          <Feedback.badge variant={:outline}>Component examples</Feedback.badge>
          <h2 class="site-section-title">The library should look like the product you want to ship.</h2>
        </div>
        <p class="site-section-copy">
          These previews use the real components, not marketing-only illustrations. The docs and your app render from the same primitives.
        </p>
      </div>
      <div class="grid gap-4 xl:grid-cols-2">
        <.marketing_example_card
          :for={card <- @cards}
          title={card.title}
          description={card.description}
          preview_html={card.preview_html}
          snippet={card.snippet}
          shadcn_component_url={card.shadcn_component_url}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  defp button_group_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Actions.button_group>
        <Actions.button>Deploy</Actions.button>
        <Actions.button variant={:outline}>Rollback</Actions.button>
      </Actions.button_group>
      """)

    snippet = """
    <.button_group>
      <.button>Deploy</.button>
      <.button variant={:outline}>Rollback</.button>
    </.button_group>
    """

    %{
      title: "Actions.button_group",
      description: "Grouped primary + secondary actions.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/button"
    }
  end

  defp form_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Forms.field>
        <:label>
          <Forms.label for="site-email">Team email</Forms.label>
        </:label>
        <Forms.input id="site-email" placeholder="team@example.com" />
        <:description>Used for release announcements.</:description>
        <div class="pt-2">
          <Forms.switch id="site-updates" checked={true}>Send release updates</Forms.switch>
        </div>
      </Forms.field>
      """)

    snippet = """
    <.field>
      <:label><.label for="site-email">Team email</.label></:label>
      <.input id="site-email" placeholder="team@example.com" />
      <:description>Used for release announcements.</:description>
    </.field>
    """

    %{
      title: "Forms.field",
      description: "Label + input + helper text using the shared token model.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/form"
    }
  end

  defp alert_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Feedback.alert>
        <Icons.icon name="circle-alert" class="size-4" />
        <Feedback.alert_title>Release ready</Feedback.alert_title>
        <Feedback.alert_description>
          All quality checks passed. Publish when ready.
        </Feedback.alert_description>
      </Feedback.alert>
      """)

    snippet = """
    <.alert>
      <.icon name="circle-alert" class="size-4" />
      <.alert_title>Release ready</.alert_title>
      <.alert_description>All quality checks passed.</.alert_description>
    </.alert>
    """

    %{
      title: "Feedback.alert",
      description: "Status messaging aligned with upstream alert patterns.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/alert"
    }
  end

  defp tabs_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Navigation.tabs value="overview">
        <:trigger value="overview">Overview</:trigger>
        <:trigger value="api">API</:trigger>
        <:content value="overview">Use components directly in HEEx templates.</:content>
        <:content value="api">Typed attrs/slots with compile-time checks.</:content>
      </Navigation.tabs>
      """)

    snippet = """
    <.tabs value="overview">
      <:trigger value="overview">Overview</:trigger>
      <:trigger value="api">API</:trigger>
      <:content value="overview">Use components in HEEx.</:content>
      <:content value="api">Typed attrs/slots with compile-time checks.</:content>
    </.tabs>
    """

    %{
      title: "Navigation.tabs",
      description: "Tab primitives with server-driven active state.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/tabs"
    }
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :preview_html, :string, required: true
  attr :snippet, :string, required: true
  attr :shadcn_component_url, :string, required: true

  defp marketing_example_card(assigns) do
    ~H"""
    <Layout.panel class="site-example-card h-full divide-y overflow-hidden">
      <div class="site-example-card-header p-4">
        <h4 class="font-medium">{@title}</h4>
        <p class="text-muted-foreground mt-1 text-sm">{@description}</p>
      </div>

      <div
        data-slot="preview"
        class="site-example-preview bg-background flex min-h-[10rem] flex-1 items-center justify-center p-5"
      >
        {rendered(@preview_html)}
      </div>

      <div data-slot="code" class="site-example-code relative min-w-0 border-t">
        <Docs.docs_code_block
          source={@snippet}
          language={:heex}
          pre_class="m-0 min-w-0 max-w-full max-h-56 overflow-x-auto overflow-y-auto p-4 pr-12 text-xs leading-4"
        />
      </div>
    </Layout.panel>
    """
  end

  defp install_html(version, docs_path) do
    deps_code = """
    def deps do
      [
        {:cinder_ui, "~> #{version}"},
        {:lucide_icons, "~> 2.0"} # optional, recommended for <.icon />
      ]
    end
    """

    terminal_code = """
    mix deps.get
    mix cinder_ui.install --skip-existing
    """

    assigns = %{
      deps_code: deps_code,
      terminal_code: terminal_code,
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <section id="install" class="site-section">
      <div class="site-section-heading">
        <div>
          <Feedback.badge variant={:outline}>Quick start</Feedback.badge>
          <h2 class="site-section-title">Install in your Phoenix app</h2>
        </div>
        <p class="site-section-copy">
          Need the full setup flow?
          <a href={@install_docs_path} class="underline underline-offset-4">Read the installation guide</a>.
        </p>
      </div>

      <div class="site-install-grid">
        <Layout.card class="site-install-card">
          <Layout.card_header class="border-b">
            <Layout.card_title>What the installer handles</Layout.card_title>
            <Layout.card_description>
              Tailwind scanning, theme CSS, LiveView hook wiring, and package manager detection.
            </Layout.card_description>
          </Layout.card_header>
          <Layout.card_content class="space-y-4">
            <ol class="site-steps">
              <li>
                <span class="site-step-index">01</span>
                Add the package and optional icons dependency.
              </li>
              <li>
                <span class="site-step-index">02</span>
                Run the installer to wire CSS, JS hooks, and Tailwind sources.
              </li>
              <li>
                <span class="site-step-index">03</span>
                Start composing components directly in HEEx.
              </li>
            </ol>
            <Feedback.alert>
              <Icons.icon name="wand-sparkles" class="size-4" />
              <Feedback.alert_title>Designed for existing Phoenix apps</Feedback.alert_title>
              <Feedback.alert_description>
                The install task patches common entry points instead of assuming a greenfield scaffold.
              </Feedback.alert_description>
            </Feedback.alert>
          </Layout.card_content>
        </Layout.card>

        <div class="space-y-4">
          <div class="space-y-2">
            <p class="text-sm font-medium text-foreground">1) Add dependencies to <code>mix.exs</code></p>
            <Docs.docs_code_block
              source={@deps_code}
              language={:elixir}
              pre_class="site-code-shell relative rounded-lg border px-4 py-3 text-sm"
            />
          </div>
          <div class="space-y-2">
            <p class="text-sm font-medium text-foreground">
              2) Install and run setup commands in your terminal
            </p>
            <Docs.docs_code_block
              source={@terminal_code}
              language={:bash}
              pre_class="site-code-shell relative rounded-lg border px-4 py-3 text-sm"
            />
          </div>
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp theme_tokens_html do
    tokens_code = """
    :root {
      --background: oklch(1 0 0);
      --foreground: oklch(0.145 0 0);
      --card: oklch(1 0 0);
      --card-foreground: oklch(0.145 0 0);
      --popover: oklch(1 0 0);
      --popover-foreground: oklch(0.145 0 0);
      --primary: oklch(0.205 0 0);
      --primary-foreground: oklch(0.985 0 0);
      --secondary: oklch(0.97 0 0);
      --secondary-foreground: oklch(0.205 0 0);
      --muted: oklch(0.97 0 0);
      --muted-foreground: oklch(0.556 0 0);
      --accent: oklch(0.97 0 0);
      --accent-foreground: oklch(0.205 0 0);
      --destructive: oklch(0.577 0.245 27.325);
      --destructive-foreground: oklch(0.985 0 0);
      --border: oklch(0.922 0 0);
      --input: oklch(0.922 0 0);
      --ring: oklch(0.708 0 0);
      --radius: 0.75rem;
    }

    .dark {
      --background: oklch(0.145 0 0);
      --foreground: oklch(0.985 0 0);
      --card: oklch(0.205 0 0);
      --card-foreground: oklch(0.985 0 0);
      --popover: oklch(0.205 0 0);
      --popover-foreground: oklch(0.985 0 0);
      --primary: oklch(0.922 0 0);
      --primary-foreground: oklch(0.205 0 0);
      --secondary: oklch(0.269 0 0);
      --secondary-foreground: oklch(0.985 0 0);
      --muted: oklch(0.269 0 0);
      --muted-foreground: oklch(0.708 0 0);
      --accent: oklch(0.269 0 0);
      --accent-foreground: oklch(0.985 0 0);
      --destructive: oklch(0.704 0.191 22.216);
      --destructive-foreground: oklch(0.985 0 0);
      --border: oklch(1 0 0 / 10%);
      --input: oklch(1 0 0 / 15%);
      --ring: oklch(0.556 0 0);
    }
    """

    assigns = %{tokens_code: tokens_code}

    ~H"""
    <section id="tokens" class="site-section">
      <div class="site-section-heading">
        <div>
          <Feedback.badge variant={:outline}>Theme tokens</Feedback.badge>
          <h2 class="site-section-title">Configure tokens like shadcn/ui</h2>
        </div>
        <p class="site-section-copy">
          Override semantic CSS variables in <code>assets/css/app.css</code>. Radius, surfaces, and emphasis all flow from the token set.
        </p>
      </div>

      <div class="site-token-grid">
        <Layout.card class="site-token-card">
          <Layout.card_header class="border-b">
            <Layout.card_title>Semantic palette</Layout.card_title>
            <Layout.card_description>
              One token model drives docs, examples, and application UI.
            </Layout.card_description>
          </Layout.card_header>
          <Layout.card_content class="space-y-4">
            <div class="site-token-swatches">
              <div class="site-token-swatch">
                <span class="site-token-chip site-token-chip-background"></span>
                <div>
                  <p class="font-medium">Background</p>
                  <p class="text-xs text-muted-foreground">Base canvas and shells</p>
                </div>
              </div>
              <div class="site-token-swatch">
                <span class="site-token-chip site-token-chip-primary"></span>
                <div>
                  <p class="font-medium">Primary</p>
                  <p class="text-xs text-muted-foreground">Actions and emphasis</p>
                </div>
              </div>
              <div class="site-token-swatch">
                <span class="site-token-chip site-token-chip-muted"></span>
                <div>
                  <p class="font-medium">Muted</p>
                  <p class="text-xs text-muted-foreground">Secondary surfaces</p>
                </div>
              </div>
            </div>

            <div class="flex flex-wrap gap-2">
              <Feedback.badge>Primary action</Feedback.badge>
              <Feedback.badge variant={:secondary}>Secondary</Feedback.badge>
              <Feedback.badge variant={:outline}>Outline</Feedback.badge>
            </div>
          </Layout.card_content>
        </Layout.card>

        <Docs.docs_code_block
          source={@tokens_code}
          language={:css}
          pre_class="site-code-shell relative rounded-lg border px-4 py-3 text-sm"
        />
      </div>
    </section>
    """
    |> to_html()
  end

  defp features_html(shadcn_url) do
    assigns = %{
      features: [
        %{
          icon_name: "layers-3",
          title: "Phoenix-native API",
          body_html:
            "Typed HEEx function components with predictable attrs/slots and composable primitives."
        },
        %{
          icon_name: "wand-sparkles",
          title: "Fast app integration",
          body_html:
            "One command setup for Tailwind source wiring, component CSS, and optional LiveView hooks in existing projects."
        },
        %{
          icon_name: "palette",
          title: "shadcn-aligned styles",
          body_html:
            "Broad API surface aligned with <a href=\"#{shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"underline underline-offset-4\">shadcn/ui</a> conventions and token semantics."
        },
        %{
          icon_name: "shield-check",
          title: "Production confidence",
          body_html:
            "Unit, browser, and visual regression coverage keeps components stable as your app evolves."
        }
      ]
    }

    ~H"""
    <section class="site-section space-y-6">
      <div class="site-section-heading">
        <div>
          <Feedback.badge variant={:outline}>Why teams use it</Feedback.badge>
          <h2 class="site-section-title">A design system delivery vehicle for Phoenix teams.</h2>
        </div>
        <p class="site-section-copy">
          The goal is not novelty for its own sake. It is faster, more coherent product delivery with a component surface that feels familiar to modern frontend teams.
        </p>
      </div>
      <div class="grid gap-4 md:grid-cols-2">
        <.marketing_feature_card
          :for={feature <- @features}
          icon_name={feature.icon_name}
          title={feature.title}
          body_html={feature.body_html}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  attr :title, :string, required: true
  attr :icon_name, :string, required: true
  attr :body_html, :string, required: true

  defp marketing_feature_card(assigns) do
    ~H"""
    <Layout.card class="site-feature-card">
      <Layout.card_header>
        <div class="site-feature-icon">
          <Icons.icon name={@icon_name} class="size-4" />
        </div>
        <Layout.card_title>{@title}</Layout.card_title>
      </Layout.card_header>
      <Layout.card_content>
        <Layout.card_description>
          {rendered(@body_html)}
        </Layout.card_description>
      </Layout.card_content>
    </Layout.card>
    """
  end

  defp theme_bootstrap_script do
    "<script>\n#{template!("theme_bootstrap.js")}\n</script>"
  end

  defp template!(name), do: File.read!(Path.join(@template_dir, name))

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)
end
