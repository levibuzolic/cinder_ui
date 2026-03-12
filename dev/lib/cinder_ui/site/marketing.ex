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
      features_html: features_html(shadcn_url, docs_path),
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
      <Actions.button as="a" href={@docs_path} variant={:ghost} size={:sm}>
        Components
      </Actions.button>
      <Docs.docs_external_link_button
        :if={is_binary(@github_url) and @github_url != ""}
        href={@github_url}
        variant={:ghost}
        size={:sm}
      >
        GitHub
      </Docs.docs_external_link_button>
      <Docs.docs_external_link_button
        :if={is_binary(@hex_url) and @hex_url != ""}
        href={@hex_url}
        variant={:ghost}
        size={:sm}
      >
        Hex
      </Docs.docs_external_link_button>
      <Docs.docs_external_link_button
        :if={is_binary(@hexdocs_url) and @hexdocs_url != ""}
        href={@hexdocs_url}
        variant={:ghost}
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
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <section class="home-hero relative overflow-hidden border-b">
      <div class="home-hero-grid absolute inset-0"></div>
      <div class="relative mx-auto max-w-[1200px] px-4 py-20 md:px-6 md:py-32">
        <div class="mx-auto max-w-3xl space-y-8">
          <div class="flex flex-wrap items-center gap-2">
            <Feedback.badge variant={:outline}>v{@version}</Feedback.badge>
            <Feedback.badge variant={:secondary}>{@component_count} components</Feedback.badge>
          </div>

          <h1 class="text-5xl font-thin leading-[1.08] tracking-tight sm:text-6xl lg:text-7xl">
            Build <span class="font-black">beautiful</span> Phoenix apps with
            <span class="font-black">production-ready</span> components
          </h1>

          <p class="max-w-xl text-lg text-muted-foreground">
            Server-rendered HEEx components with typed APIs, aligned with
            <a
              href={@shadcn_url}
              target="_blank"
              rel="noopener noreferrer"
              class="font-medium text-foreground underline underline-offset-4"
            >
              shadcn/ui
            </a>
            conventions. One command to install.
          </p>

          <div class="flex flex-wrap gap-3">
            <Actions.button as="a" href={@docs_path} size={:lg}>
              Browse Components
            </Actions.button>
            <Actions.button as="a" variant={:outline} href={@install_docs_path} size={:lg}>
              Installation Guide
            </Actions.button>
            <Actions.button as="a" variant={:outline} href="#install" size={:lg}>
              Quick Start
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
      button_card: button_group_example_card(shadcn_url),
      form_card: form_example_card(shadcn_url),
      alert_card: alert_example_card(shadcn_url),
      tabs_card: tabs_example_card(shadcn_url),
      badge_card: badge_example_card(shadcn_url)
    }

    ~H"""
    <section id="examples" class="mx-auto max-w-[1200px] px-4 py-16 md:px-6 md:py-24">
      <div class="mb-10 flex items-end gap-4">
        <span class="home-section-number">01</span>
        <div>
          <h2 class="text-3xl font-black tracking-tight sm:text-4xl">See it in action</h2>
          <p class="mt-2 text-muted-foreground">Real components, rendered server-side with HEEx.</p>
        </div>
      </div>

      <div class="home-bento-grid">
        <div class="home-bento-wide">
          <.marketing_example_card
            title={@button_card.title}
            description={@button_card.description}
            preview_html={@button_card.preview_html}
            snippet={@button_card.snippet}
            shadcn_component_url={@button_card.shadcn_component_url}
          />
        </div>
        <div class="home-bento-tall">
          <.marketing_example_card
            title={@form_card.title}
            description={@form_card.description}
            preview_html={@form_card.preview_html}
            snippet={@form_card.snippet}
            shadcn_component_url={@form_card.shadcn_component_url}
          />
        </div>
        <div>
          <.marketing_example_card
            title={@alert_card.title}
            description={@alert_card.description}
            preview_html={@alert_card.preview_html}
            snippet={@alert_card.snippet}
            shadcn_component_url={@alert_card.shadcn_component_url}
          />
        </div>
        <div>
          <.marketing_example_card
            title={@tabs_card.title}
            description={@tabs_card.description}
            preview_html={@tabs_card.preview_html}
            snippet={@tabs_card.snippet}
            shadcn_component_url={@tabs_card.shadcn_component_url}
          />
        </div>
        <div>
          <.marketing_example_card
            title={@badge_card.title}
            description={@badge_card.description}
            preview_html={@badge_card.preview_html}
            snippet={@badge_card.snippet}
            shadcn_component_url={@badge_card.shadcn_component_url}
          />
        </div>
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
      title: "Button Group",
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
      <:label><.label for="email">Team email</.label></:label>
      <.input id="email" placeholder="team@example.com" />
      <:description>Used for announcements.</:description>
    </.field>
    """

    %{
      title: "Form Field",
      description: "Label + input + helper text with the shared token model.",
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
      <.alert_description>All checks passed.</.alert_description>
    </.alert>
    """

    %{
      title: "Alert",
      description: "Status messaging with upstream alert patterns.",
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
      <:content value="api">Typed attrs/slots.</:content>
    </.tabs>
    """

    %{
      title: "Tabs",
      description: "Tab primitives with server-driven active state.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/tabs"
    }
  end

  defp badge_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <div class="flex flex-wrap items-center gap-2">
        <Feedback.badge>Default</Feedback.badge>
        <Feedback.badge variant={:secondary}>Secondary</Feedback.badge>
        <Feedback.badge variant={:outline}>Outline</Feedback.badge>
        <Feedback.badge variant={:destructive}>Destructive</Feedback.badge>
      </div>
      """)

    snippet = """
    <.badge>Default</.badge>
    <.badge variant={:secondary}>Secondary</.badge>
    <.badge variant={:outline}>Outline</.badge>
    <.badge variant={:destructive}>Destructive</.badge>
    """

    %{
      title: "Badge",
      description: "Status labels in multiple variants.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/badge"
    }
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :preview_html, :string, required: true
  attr :snippet, :string, required: true
  attr :shadcn_component_url, :string, required: true

  defp marketing_example_card(assigns) do
    ~H"""
    <Layout.panel class="home-example-card h-full divide-y">
      <div class="p-4">
        <h4 class="font-medium">{@title}</h4>
        <p class="text-muted-foreground mt-1 text-sm">{@description}</p>
      </div>

      <div
        data-slot="preview"
        class="bg-background flex min-h-[7rem] flex-1 items-center justify-center p-4"
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
    <section id="install" class="mx-auto max-w-[1200px] px-4 py-16 md:px-6 md:py-24">
      <div class="mb-10 flex items-end gap-4">
        <span class="home-section-number">02</span>
        <div>
          <h2 class="text-3xl font-black tracking-tight sm:text-4xl">Get started in 60 seconds</h2>
          <p class="mt-2 text-muted-foreground">
            Two steps. No boilerplate.
            <a href={@install_docs_path} class="font-medium text-foreground underline underline-offset-4">Read the full guide</a>.
          </p>
        </div>
      </div>

      <div class="mx-auto grid max-w-3xl gap-8">
        <div class="space-y-3">
          <p class="text-sm font-medium text-foreground">
            <span class="mr-2 inline-flex size-6 items-center justify-center rounded-full bg-primary text-xs font-bold text-primary-foreground">1</span>
            Add dependencies to <code class="inline-code">mix.exs</code>
          </p>
          <Docs.docs_code_block
            source={@deps_code}
            language={:elixir}
            pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
          />
        </div>
        <div class="space-y-3">
          <p class="text-sm font-medium text-foreground">
            <span class="mr-2 inline-flex size-6 items-center justify-center rounded-full bg-primary text-xs font-bold text-primary-foreground">2</span>
            Fetch and install
          </p>
          <Docs.docs_code_block
            source={@terminal_code}
            language={:bash}
            pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
          />
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp features_html(shadcn_url, docs_path) do
    assigns = %{
      docs_path: docs_path,
      features: [
        %{
          icon: "blocks",
          title: "Phoenix-native API",
          description:
            "Typed HEEx function components with predictable attrs, slots, and composable primitives."
        },
        %{
          icon: "zap",
          title: "One-command setup",
          description:
            "Single installer wires Tailwind sources, component CSS, and optional LiveView hooks."
        },
        %{
          icon: "paintbrush",
          title: "Themeable design tokens",
          description:
            "Customize colors, radius, and spacing through CSS variables \u2014 aligned with <a href=\"#{shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"underline underline-offset-4\">shadcn/ui</a> conventions."
        },
        %{
          icon: "shield-check",
          title: "Production tested",
          description:
            "Unit, browser, and visual regression coverage keeps components stable as your app evolves."
        }
      ]
    }

    ~H"""
    <section class="mx-auto max-w-[1200px] px-4 py-16 md:px-6 md:py-24">
      <div class="mb-10 flex items-end gap-4">
        <span class="home-section-number">03</span>
        <div>
          <h2 class="text-3xl font-black tracking-tight sm:text-4xl">What you get</h2>
          <p class="mt-2 text-muted-foreground">Everything you need to ship polished Phoenix apps.</p>
        </div>
      </div>

      <div class="grid gap-6 sm:grid-cols-2">
        <.marketing_feature_card
          :for={feature <- @features}
          icon={feature.icon}
          title={feature.title}
          description={feature.description}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true

  defp marketing_feature_card(assigns) do
    ~H"""
    <Layout.card class="home-feature-card">
      <Layout.card_header>
        <div class="mb-2 flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
          <Icons.icon name={@icon} class="size-5" />
        </div>
        <Layout.card_title>{@title}</Layout.card_title>
      </Layout.card_header>
      <Layout.card_content>
        <Layout.card_description>
          {rendered(@description)}
        </Layout.card_description>
      </Layout.card_content>
    </Layout.card>
    """
  end

  defp footer_cta_html(docs_path) do
    assigns = %{
      docs_path: docs_path,
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <Actions.button as="a" href={@docs_path} size={:lg}>
      Browse Components
    </Actions.button>
    <Actions.button as="a" variant={:outline} href={@install_docs_path} size={:lg}>
      Installation Guide
    </Actions.button>
    """
    |> to_html()
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
