defmodule Demo.SiteRenderer do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Docs.UIComponents
  alias CinderUI.Site.Marketing
  alias Demo.SiteRuntime
  alias Phoenix.HTML.Safe

  @theme_bootstrap_path Path.expand("../../../priv/site_templates/theme_bootstrap.js", __DIR__)

  def marketing_html do
    Marketing.render_marketing_html(%{
      component_count: SiteRuntime.catalog_component_count(),
      docs_path: "./docs/",
      theme_script_src: "./assets/static_docs.js",
      theme_css_path: "./assets/theme.css",
      site_css_path: "./assets/site.css"
    })
  end

  def docs_index_html do
    sections = SiteRuntime.catalog_sections()
    root_prefix = "."
    asset_prefix = ".."

    page_shell(
      title: "Cinder UI Docs",
      description: "Component docs for Cinder UI",
      body_content: docs_index_body(sections, root_prefix),
      sections: sections,
      active_entry_id: nil,
      active_page: :overview,
      root_prefix: root_prefix,
      home_url: "../",
      asset_prefix: asset_prefix,
      github_url: SiteRuntime.github_url(),
      hex_package_url: SiteRuntime.hex_package_url()
    )
  end

  def docs_component_html(entry) do
    sections = SiteRuntime.catalog_sections()
    root_prefix = ".."
    asset_prefix = "../.."

    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: docs_component_body(entry, sections, root_prefix),
      sections: sections,
      active_entry_id: entry.id,
      active_page: nil,
      root_prefix: root_prefix,
      home_url: "../../",
      asset_prefix: asset_prefix,
      github_url: SiteRuntime.github_url(),
      hex_package_url: SiteRuntime.hex_package_url()
    )
  end

  def install_html do
    sections = SiteRuntime.catalog_sections()
    root_prefix = ".."
    asset_prefix = "../.."

    page_shell(
      title: "Installation · Cinder UI",
      description: "How to install Cinder UI in your Phoenix project",
      body_content: install_body(),
      sections: sections,
      active_entry_id: nil,
      active_page: :install,
      root_prefix: root_prefix,
      home_url: "../../",
      asset_prefix: asset_prefix,
      github_url: SiteRuntime.github_url(),
      hex_package_url: SiteRuntime.hex_package_url()
    )
  end

  defp page_shell(opts) do
    assigns = %{
      title: opts[:title],
      description: opts[:description],
      body_content: opts[:body_content],
      sections: opts[:sections],
      active_entry_id: opts[:active_entry_id],
      active_page: opts[:active_page],
      root_prefix: opts[:root_prefix],
      home_url: opts[:home_url],
      asset_prefix: opts[:asset_prefix],
      github_url: opts[:github_url],
      hex_package_url: opts[:hex_package_url]
    }

    ~H"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@title}</title>
        <meta name="description" content={@description} />
        {rendered(theme_bootstrap_script())}
        <link rel="stylesheet" href={"#{@asset_prefix}/assets/theme.css"} />
        <link rel="stylesheet" href={"#{@asset_prefix}/assets/site.css"} />
      </head>
      <body class="bg-background text-foreground">
        <UIComponents.docs_layout
          sections={@sections}
          mode={:static}
          root_prefix={@root_prefix}
          active_entry_id={@active_entry_id}
          active_page={@active_page}
          home_url={@home_url}
          github_url={@github_url}
          hex_package_url={@hex_package_url}
        >
          {rendered(@body_content)}
        </UIComponents.docs_layout>

        <script type="module" src={"#{@asset_prefix}/assets/static_docs.js"}>
        </script>
      </body>
    </html>
    """
    |> to_html()
  end

  defp docs_index_body(sections, root_prefix) do
    assigns = %{
      sections: sections,
      component_count: SiteRuntime.catalog_component_count(),
      root_prefix: root_prefix
    }

    ~H"""
    <UIComponents.docs_overview_intro component_count={@component_count} show_count={true} />

    <UIComponents.docs_overview_sections
      sections={@sections}
      mode={:static}
      root_prefix={@root_prefix}
    />
    """
    |> to_html()
  end

  defp docs_component_body(entry, sections, root_prefix) do
    assigns = %{entry: entry, sections: sections, root_prefix: root_prefix}

    ~H"""
    <UIComponents.docs_component_detail
      entry={@entry}
      sections={@sections}
      mode={:static}
      root_prefix={@root_prefix}
    />
    """
    |> to_html()
  end

  defp install_body do
    assigns = %{}

    ~H"""
    <div class="docs-markdown prose prose-neutral dark:prose-invert max-w-3xl">
      <h1>Installation</h1>
      <p>
        Cinder UI is a component library for Phoenix LiveView applications.
        Follow these steps to add it to your project.
      </p>

      <h2 id="prerequisites">Prerequisites</h2>
      <p>You need an existing Phoenix 1.7+ project. If you don't have one yet:</p>
      <UIComponents.docs_code_block
        source="mix phx.new my_app
    cd my_app"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />

      <h2 id="tailwind-css">1. Set up Tailwind CSS</h2>
      <p>
        Cinder UI requires Tailwind CSS v4+. New Phoenix projects generated with
        <code>mix phx.new</code>
        include Tailwind by default — if yours already has
        it, skip to <a href="#add-cinder-ui">step 2</a>.
      </p>
      <p>Add the Tailwind plugin to your dependencies in <code>mix.exs</code>:</p>
      <UIComponents.docs_code_block
        source={"defp deps do\n  [\n    {:tailwind, \"~> 0.3\", runtime: Mix.env() == :dev},\n    # ...\n  ]\nend"}
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Configure Tailwind in <code>config/config.exs</code>:</p>
      <UIComponents.docs_code_block
        source={"config :tailwind,\n  version: \"4.1.12\",\n  my_app: [\n    args: ~w(\n      --input=assets/css/app.css\n      --output=priv/static/assets/app.css\n    ),\n    cd: Path.expand(\"..\", __DIR__)\n  ]"}
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Add the Tailwind watcher in <code>config/dev.exs</code>:</p>
      <UIComponents.docs_code_block
        source="config :my_app, MyAppWeb.Endpoint,
    watchers: [
    tailwind: {Tailwind, :install_and_run, [:my_app, ~w(--watch)]}
    ]"
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Add Tailwind to the deployment alias in <code>mix.exs</code>:</p>
      <UIComponents.docs_code_block
        source={"defp aliases do\n  [\n    \"assets.deploy\": [\n      \"tailwind my_app --minify\",\n      \"esbuild my_app --minify\",\n      \"phx.digest\"\n    ]\n  ]\nend"}
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Install Tailwind and fetch dependencies:</p>
      <UIComponents.docs_code_block
        source="mix deps.get
    mix tailwind.install"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Set up <code>assets/css/app.css</code>:</p>
      <UIComponents.docs_code_block
        source={"@import \"tailwindcss\";"}
        language={:css}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>
        If your <code>assets/js/app.js</code> imports CSS
        (<code>import "../css/app.css"</code>), remove that line — Tailwind
        handles CSS compilation separately.
      </p>

      <h2 id="add-cinder-ui">2. Add Cinder UI</h2>
      <p>Add the dependency to your <code>mix.exs</code>:</p>
      <UIComponents.docs_code_block
        source={"defp deps do\n  [\n    {:cinder_ui, \"~> 0.1.0\"},\n    # Optional but recommended — required for the <.icon /> component\n    {:lucide_icons, \"~> 2.0\"},\n    # ...\n  ]\nend"}
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Fetch dependencies:</p>
      <UIComponents.docs_code_block
        source="mix deps.get"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />

      <h2 id="run-installer">3. Run the installer</h2>
      <p>
        Cinder UI includes a Mix task that sets up CSS, JavaScript hooks,
        and Tailwind plugins automatically:
      </p>
      <UIComponents.docs_code_block
        source="mix cinder_ui.install"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>This will:</p>
      <ul>
        <li>
          Copy <code>cinder_ui.css</code>
          into <code>assets/css/</code>
          (theme variables and dark mode)
        </li>
        <li>
          Copy <code>cinder_ui.js</code>
          into <code>assets/js/</code>
          (LiveView hooks for interactive components)
        </li>
        <li>
          Update <code>assets/css/app.css</code> with:<br />
          <code>@source "../../deps/cinder_ui";</code> — so Tailwind scans component classes<br />
          <code>@import "./cinder_ui.css";</code> — loads theme tokens
        </li>
        <li>
          Update <code>assets/js/app.js</code>
          to merge <code>CinderUIHooks</code>
          into your LiveView hooks
        </li>
        <li>Install the <code>tailwindcss-animate</code> npm package</li>
      </ul>
      <p>
        The installer auto-detects your package manager (npm, pnpm, yarn, or bun). To specify one explicitly:
      </p>
      <UIComponents.docs_code_block
        source="mix cinder_ui.install --package-manager pnpm"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>To re-run without overwriting customized files:</p>
      <UIComponents.docs_code_block
        source="mix cinder_ui.install --skip-existing"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>To only copy generated Cinder UI assets and skip patching app entry files:</p>
      <UIComponents.docs_code_block
        source="mix cinder_ui.install --skip-patching"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />

      <h2 id="configure-app">4. Configure your app</h2>
      <p>
        Add <code>use CinderUI</code>
        to your app's <code>html_helpers</code>
        in <code>lib/my_app_web.ex</code>:
      </p>
      <UIComponents.docs_code_block
        source="defp html_helpers do
    quote do
    use Phoenix.Component
    use CinderUI
    # ...
    end
    end"
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Or selectively import only the modules you need:</p>
      <UIComponents.docs_code_block
        source="import CinderUI.Components.Actions
    import CinderUI.Components.Forms"
        language={:elixir}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />

      <h2 id="verify">5. Start building</h2>
      <p>Start your Phoenix server:</p>
      <UIComponents.docs_code_block
        source="mix phx.server"
        language={:bash}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
      <p>Try a component in any template:</p>
      <UIComponents.docs_code_block
        source="<.button>Click me</.button>"
        language={:heex}
        pre_class="my-4 overflow-x-auto rounded-lg border bg-muted/30 p-4 text-sm"
      />
    </div>
    """
    |> to_html()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp theme_bootstrap_script do
    "<script>\n#{File.read!(@theme_bootstrap_path)}\n</script>"
  end

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
