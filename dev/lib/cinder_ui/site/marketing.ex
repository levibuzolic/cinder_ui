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
      install_docs_path: Path.join(docs_path, "install/"),
      embers: hero_embers()
    }

    ~H"""
    <section class="hero-section py-20 md:py-28">
      <div class="hero-backdrop" aria-hidden="true">
        <div class="hero-glow"></div>
        <div class="hero-heat"></div>
        <div class="hero-embers">
          <span
            :for={ember <- @embers}
            class="hero-ember"
            style={hero_ember_style(ember)}
          >
          </span>
        </div>
        <div class="hero-falloff"></div>
        <div class="hero-beam hero-beam-left"></div>
        <div class="hero-beam hero-beam-right"></div>
      </div>
      <div class="mx-auto max-w-[1100px] px-4 md:px-6">
        <div class="hero-content flex flex-col items-center text-center space-y-6">
          <h1
            class="hero-heading heading-gradient text-5xl font-bold tracking-tight sm:text-6xl max-w-3xl leading-[1.1]"
            data-text="Forge beautiful interfaces with Phoenix"
          >
            Forge beautiful interfaces with Phoenix
          </h1>
          <p class="hero-copy max-w-2xl text-lg text-muted-foreground leading-relaxed">
            Production-ready components inspired by shadcn/ui. Typed HEEx APIs, seamless LiveView integration, and one-command installation.
          </p>
          <div class="hero-badges flex flex-wrap items-center justify-center gap-2">
            <Feedback.badge variant={:outline} class="hero-pill">
              v{@version}
            </Feedback.badge>
            <Feedback.badge variant={:outline} class="hero-pill">
              {@component_count} components
            </Feedback.badge>
          </div>
          <div class="hero-actions flex flex-wrap justify-center gap-3 pt-2">
            <Actions.button
              as="a"
              href={@docs_path}
              size={:lg}
              class="hero-button hero-button-primary"
            >
              Explore Components
            </Actions.button>
            <Actions.button
              as="a"
              variant={:outline}
              href="#install"
              size={:lg}
              class="hero-button hero-button-outline"
            >
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
        <p class="hero-copy text-muted-foreground max-w-lg mx-auto">
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
    <Layout.panel class="marketing-surface glass-card h-full divide-y rounded-xl">
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

      <div data-slot="code" class="relative min-w-0">
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
          Two steps to production-ready components. <a
            href={@install_docs_path}
            class="underline underline-offset-4"
          >Full installation guide</a>.
        </p>
      </div>
      <div class="mx-auto max-w-2xl space-y-4">
        <div class="space-y-2">
          <p class="text-sm font-medium text-foreground">
            1. Add dependencies to <code class="text-sm">mix.exs</code>
          </p>
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
    <Layout.card class="marketing-surface glass-card rounded-xl">
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

  defp hero_embers do
    [
      %{
        x: "8%",
        y: "-3%",
        size: "0.34rem",
        rise: "20rem",
        drift: "1.6rem",
        sway: "2.2rem",
        duration: "12.8s",
        delay: "-8.2s",
        blur: "0.4px",
        opacity: "0.52"
      },
      %{
        x: "14%",
        y: "6%",
        size: "0.48rem",
        rise: "22rem",
        drift: "-1.8rem",
        sway: "2.8rem",
        duration: "10.4s",
        delay: "-5.6s",
        blur: "0.2px",
        opacity: "0.76"
      },
      %{
        x: "18%",
        y: "0%",
        size: "0.26rem",
        rise: "18rem",
        drift: "1.2rem",
        sway: "1.8rem",
        duration: "13.6s",
        delay: "-9.8s",
        blur: "0.7px",
        opacity: "0.44"
      },
      %{
        x: "23%",
        y: "12%",
        size: "0.56rem",
        rise: "24rem",
        drift: "2.4rem",
        sway: "3.2rem",
        duration: "11.2s",
        delay: "-1.8s",
        blur: "0.3px",
        opacity: "0.8"
      },
      %{
        x: "28%",
        y: "-4%",
        size: "0.42rem",
        rise: "19rem",
        drift: "-1.2rem",
        sway: "1.6rem",
        duration: "9.8s",
        delay: "-6.3s",
        blur: "0.4px",
        opacity: "0.66"
      },
      %{
        x: "32%",
        y: "10%",
        size: "0.3rem",
        rise: "17rem",
        drift: "0.8rem",
        sway: "1.4rem",
        duration: "14.3s",
        delay: "-11.4s",
        blur: "0.8px",
        opacity: "0.42"
      },
      %{
        x: "37%",
        y: "4%",
        size: "0.62rem",
        rise: "25rem",
        drift: "-2.7rem",
        sway: "3.4rem",
        duration: "12.1s",
        delay: "-3.7s",
        blur: "0.2px",
        opacity: "0.84"
      },
      %{
        x: "41%",
        y: "-2%",
        size: "0.24rem",
        rise: "16rem",
        drift: "1rem",
        sway: "1.5rem",
        duration: "8.9s",
        delay: "-4.1s",
        blur: "0.9px",
        opacity: "0.46"
      },
      %{
        x: "45%",
        y: "14%",
        size: "0.52rem",
        rise: "23rem",
        drift: "1.9rem",
        sway: "2.5rem",
        duration: "10.9s",
        delay: "-7.5s",
        blur: "0.3px",
        opacity: "0.74"
      },
      %{
        x: "50%",
        y: "2%",
        size: "0.68rem",
        rise: "27rem",
        drift: "-2.2rem",
        sway: "3.8rem",
        duration: "13.1s",
        delay: "-10.2s",
        blur: "0.2px",
        opacity: "0.9"
      },
      %{
        x: "54%",
        y: "-5%",
        size: "0.32rem",
        rise: "18rem",
        drift: "1.4rem",
        sway: "2rem",
        duration: "9.6s",
        delay: "-2.8s",
        blur: "0.6px",
        opacity: "0.54"
      },
      %{
        x: "58%",
        y: "10%",
        size: "0.44rem",
        rise: "21rem",
        drift: "-1.6rem",
        sway: "2.3rem",
        duration: "12.4s",
        delay: "-8.8s",
        blur: "0.3px",
        opacity: "0.68"
      },
      %{
        x: "61%",
        y: "5%",
        size: "0.26rem",
        rise: "15rem",
        drift: "0.9rem",
        sway: "1.2rem",
        duration: "8.2s",
        delay: "-6.9s",
        blur: "0.8px",
        opacity: "0.4"
      },
      %{
        x: "66%",
        y: "13%",
        size: "0.58rem",
        rise: "24rem",
        drift: "2.1rem",
        sway: "3rem",
        duration: "11.7s",
        delay: "-1.2s",
        blur: "0.2px",
        opacity: "0.82"
      },
      %{
        x: "70%",
        y: "-1%",
        size: "0.36rem",
        rise: "19rem",
        drift: "-1.1rem",
        sway: "1.7rem",
        duration: "10.1s",
        delay: "-9.1s",
        blur: "0.5px",
        opacity: "0.58"
      },
      %{
        x: "73%",
        y: "7%",
        size: "0.28rem",
        rise: "17rem",
        drift: "1.3rem",
        sway: "1.6rem",
        duration: "14.8s",
        delay: "-12.7s",
        blur: "0.7px",
        opacity: "0.38"
      },
      %{
        x: "78%",
        y: "2%",
        size: "0.64rem",
        rise: "26rem",
        drift: "-2.5rem",
        sway: "3.6rem",
        duration: "12.9s",
        delay: "-5.1s",
        blur: "0.2px",
        opacity: "0.88"
      },
      %{
        x: "82%",
        y: "11%",
        size: "0.46rem",
        rise: "22rem",
        drift: "1.8rem",
        sway: "2.4rem",
        duration: "9.7s",
        delay: "-7.8s",
        blur: "0.3px",
        opacity: "0.72"
      },
      %{
        x: "86%",
        y: "-4%",
        size: "0.22rem",
        rise: "14rem",
        drift: "-0.9rem",
        sway: "1.2rem",
        duration: "8.7s",
        delay: "-3.6s",
        blur: "0.9px",
        opacity: "0.34"
      },
      %{
        x: "90%",
        y: "4%",
        size: "0.4rem",
        rise: "18rem",
        drift: "1.5rem",
        sway: "2rem",
        duration: "11.5s",
        delay: "-10.8s",
        blur: "0.4px",
        opacity: "0.62"
      }
    ]
  end

  defp hero_ember_style(ember) do
    [
      "--ember-x: ",
      ember.x,
      "; ",
      "--ember-y: ",
      ember.y,
      "; ",
      "--ember-size: ",
      ember.size,
      "; ",
      "--ember-rise: ",
      ember.rise,
      "; ",
      "--ember-drift: ",
      ember.drift,
      "; ",
      "--ember-sway: ",
      ember.sway,
      "; ",
      "--ember-duration: ",
      ember.duration,
      "; ",
      "--ember-delay: ",
      ember.delay,
      "; ",
      "--ember-blur: ",
      ember.blur,
      "; ",
      "--ember-opacity: ",
      ember.opacity,
      ";"
    ]
  end

  defp template!(name), do: File.read!(Path.join(@template_dir, name))

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)
end
