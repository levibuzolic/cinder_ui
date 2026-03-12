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
      component_examples_html: component_examples_html(shadcn_url),
      install_html: install_html(version, docs_path),
      features_html: features_html(shadcn_url),
      footer_cta_html: footer_cta_html(docs_path),
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
    <div class="flex flex-wrap items-center gap-2 md:justify-end">
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

  defp hero_html(version, component_count, _shadcn_url, docs_path) do
    assigns = %{
      version: version,
      component_count: component_count,
      docs_path: docs_path,
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <section class="hero-section overflow-hidden py-20 md:py-28">
      <div class="hero-glow"></div>
      <div class="ember-dot"></div>
      <div class="ember-dot"></div>
      <div class="ember-dot"></div>
      <div class="ember-dot"></div>
      <div class="ember-dot"></div>
      <div class="mx-auto max-w-[1100px] px-4 md:px-6">
        <div class="flex flex-col items-center text-center space-y-6">
          <h1 class="heading-gradient text-5xl font-bold tracking-tight sm:text-6xl max-w-3xl leading-[1.1]">
            Forge beautiful interfaces with Phoenix
          </h1>
          <p class="max-w-2xl text-lg text-muted-foreground leading-relaxed">
            Production-ready components inspired by shadcn/ui. Typed HEEx APIs, seamless LiveView integration, and one-command installation.
          </p>
          <div class="flex flex-wrap items-center justify-center gap-2">
            <Feedback.badge variant={:outline}>
              v{@version}
            </Feedback.badge>
            <Feedback.badge variant={:outline}>
              {@component_count} components
            </Feedback.badge>
          </div>
          <div class="flex flex-wrap justify-center gap-3 pt-2">
            <Actions.button as="a" href={@docs_path} size={:lg}>
              Explore Components
            </Actions.button>
            <Actions.button as="a" variant={:outline} href="#install" size={:lg}>
              Get Started
            </Actions.button>
          </div>
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
    <section id="examples" class="space-y-6">
      <div class="text-center space-y-2">
        <h2 class="text-3xl font-semibold tracking-tight">Components that shine</h2>
        <p class="text-muted-foreground max-w-lg mx-auto">
          A growing library of production-ready components, each with typed APIs and composable slots.
        </p>
      </div>
      <div class="staggered-grid pt-4">
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
    <Layout.panel class="glass-card h-full divide-y rounded-xl">
      <div class="p-4">
        <h4 class="font-medium">{@title}</h4>
        <p class="text-muted-foreground mt-1 text-sm">{@description}</p>
      </div>

      <div
        data-slot="preview"
        class="bg-background/50 flex min-h-[7rem] flex-1 items-center justify-center p-4"
      >
        {rendered(@preview_html)}
      </div>

      <div data-slot="code" class="relative min-w-0 border-t">
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
    <section id="install" class="space-y-6">
      <div class="text-center space-y-2">
        <h2 class="text-3xl font-semibold tracking-tight">Start building</h2>
        <p class="text-muted-foreground max-w-lg mx-auto">
          Two steps to production-ready components.
          <a href={@install_docs_path} class="underline underline-offset-4">Full installation guide</a>.
        </p>
      </div>
      <div class="mx-auto max-w-2xl space-y-4">
        <div class="space-y-2">
          <p class="text-sm font-medium text-foreground">1. Add dependencies to <code class="text-sm">mix.exs</code></p>
          <Docs.docs_code_block
            source={@deps_code}
            language={:elixir}
            pre_class="install-code-block relative rounded-xl border bg-muted/30 px-4 py-3 text-sm"
          />
        </div>
        <div class="space-y-2">
          <p class="text-sm font-medium text-foreground">2. Fetch and install</p>
          <Docs.docs_code_block
            source={@terminal_code}
            language={:bash}
            pre_class="install-code-block relative rounded-xl border bg-muted/30 px-4 py-3 text-sm"
          />
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp features_html(shadcn_url) do
    assigns = %{
      features: [
        %{
          icon: "flame",
          title: "Phoenix-native",
          body_html:
            "Typed HEEx function components with predictable attrs, slots, and composable primitives built for LiveView."
        },
        %{
          icon: "download",
          title: "One-command setup",
          body_html:
            "Single installer wires Tailwind sources, component CSS, and optional LiveView hooks into existing projects."
        },
        %{
          icon: "paintbrush",
          title: "shadcn-aligned",
          body_html:
            "Broad API surface aligned with <a href=\"#{shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"underline underline-offset-4\">shadcn/ui</a> conventions, tokens, and theming."
        },
        %{
          icon: "shield-check",
          title: "Production tested",
          body_html:
            "Unit, browser, and visual regression coverage keeps components stable as your app evolves."
        }
      ]
    }

    ~H"""
    <section class="space-y-6">
      <div class="text-center space-y-2">
        <h2 class="text-3xl font-semibold tracking-tight">Why Cinder UI?</h2>
      </div>
      <div class="grid gap-4 md:grid-cols-2">
        <.marketing_feature_card
          :for={feature <- @features}
          icon={feature.icon}
          title={feature.title}
          body_html={feature.body_html}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  defp footer_cta_html(docs_path) do
    assigns = %{docs_path: docs_path}

    ~H"""
    <Actions.button as="a" href={@docs_path} size={:lg}>
      Explore the docs
    </Actions.button>
    """
    |> to_html()
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :body_html, :string, required: true

  defp marketing_feature_card(assigns) do
    ~H"""
    <Layout.card class="glass-card rounded-xl">
      <Layout.card_header>
        <div class="flex items-center gap-3">
          <div class="flex size-9 items-center justify-center rounded-lg bg-muted">
            <Icons.icon name={@icon} class="size-4 text-foreground" />
          </div>
          <Layout.card_title>{@title}</Layout.card_title>
        </div>
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
