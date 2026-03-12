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

  defp hero_html(version, component_count, shadcn_url, docs_path) do
    assigns = %{
      version: version,
      component_count: component_count,
      shadcn_url: shadcn_url,
      docs_path: docs_path,
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <section>
      <div class="grid gap-6 lg:grid-cols-[1.45fr_0.55fr]">
        <div class="space-y-4">
          <h1 class="text-4xl font-semibold tracking-tight sm:text-5xl">
            <a
              href={@shadcn_url}
              target="_blank"
              rel="noopener noreferrer"
              class="underline underline-offset-4"
            >
              shadcn/ui
            </a>
            component patterns, packaged for Phoenix + LiveView.
          </h1>
          <p class="max-w-2xl text-base text-muted-foreground">
            Cinder UI provides server-rendered components, typed attrs/slots,
            and installer automation that keep parity with
            <a
              href={@shadcn_url}
              target="_blank"
              rel="noopener noreferrer"
              class="underline underline-offset-4"
            >
              shadcn/ui
            </a>
            conventions while fitting Phoenix conventions.
          </p>
          <div class="flex flex-wrap gap-2">
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
        </div>

        <Layout.card class="lg:self-start">
          <Layout.card_content>
            <dl class="space-y-2 text-sm">
              <div class="flex items-center justify-between gap-2">
                <dt class="text-muted-foreground">Latest release</dt>
                <dd class="font-medium"><code>v{@version}</code></dd>
              </div>
              <div class="flex items-center justify-between gap-2">
                <dt class="text-muted-foreground">Components</dt>
                <dd class="font-medium"><code>{@component_count}</code></dd>
              </div>
            </dl>
          </Layout.card_content>
        </Layout.card>
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
    <section id="examples" class="space-y-4">
      <h2 class="text-2xl font-semibold tracking-tight">Component examples</h2>
      <div class="grid gap-4 md:grid-cols-2">
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
    <Layout.panel class="h-full divide-y">
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
    <section id="install" class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">Install in your Phoenix app</h2>
      <p class="text-sm text-muted-foreground">
        Need the full setup flow? <a href={@install_docs_path} class="underline underline-offset-4">Read the installation guide</a>.
      </p>
      <div class="space-y-2">
        <p class="text-sm font-medium text-foreground">1) Add dependencies to <code>mix.exs</code></p>
        <Docs.docs_code_block
          source={@deps_code}
          language={:elixir}
          pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
        />
      </div>
      <div class="space-y-2">
        <p class="text-sm font-medium text-foreground">
          2) Install and run setup commands in your terminal
        </p>
        <Docs.docs_code_block
          source={@terminal_code}
          language={:bash}
          pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
        />
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
    <section id="tokens" class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">Configure tokens like shadcn/ui</h2>
      <p class="text-sm text-muted-foreground">
        Customize your theme in <code>assets/css/app.css</code> by overriding semantic CSS variables.
        Radius is controlled via <code>--radius</code>; component radii are derived from it automatically.
      </p>
      <Docs.docs_code_block
        source={@tokens_code}
        language={:css}
        pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
      />
    </section>
    """
    |> to_html()
  end

  defp features_html(shadcn_url) do
    assigns = %{
      features: [
        %{
          title: "Phoenix-native API",
          body_html:
            "Typed HEEx function components with predictable attrs/slots and composable primitives."
        },
        %{
          title: "Fast app integration",
          body_html:
            "One command setup for Tailwind source wiring, component CSS, and optional LiveView hooks in existing projects."
        },
        %{
          title: "shadcn-aligned styles",
          body_html:
            "Broad API surface aligned with <a href=\"#{shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"underline underline-offset-4\">shadcn/ui</a> conventions and token semantics."
        },
        %{
          title: "Production confidence",
          body_html:
            "Unit, browser, and visual regression coverage keeps components stable as your app evolves."
        }
      ]
    }

    ~H"""
    <section class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">What you get</h2>
      <div class="grid gap-4 md:grid-cols-2">
        <.marketing_feature_card
          :for={feature <- @features}
          title={feature.title}
          body_html={feature.body_html}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  attr :title, :string, required: true
  attr :body_html, :string, required: true

  defp marketing_feature_card(assigns) do
    ~H"""
    <Layout.card>
      <Layout.card_header>
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
