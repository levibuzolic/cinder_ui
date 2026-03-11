defmodule Demo.SiteRenderer do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Docs.UIComponents
  alias CinderUI.Site.Marketing
  alias Demo.SiteRuntime
  alias Phoenix.HTML.Safe

  def marketing_html do
    Marketing.render_marketing_html(%{
      component_count: SiteRuntime.catalog_component_count(),
      docs_path: "./docs/",
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
      <pre><code class="language-bash">{"mix phx.new my_app\ncd my_app"}</code></pre>

      <h2 id="tailwind-css">1. Set up Tailwind CSS</h2>
      <p>
        Cinder UI requires Tailwind CSS v4+. New Phoenix projects generated with
        <code>mix phx.new</code>
        include Tailwind by default — if yours already has
        it, skip to <a href="#add-cinder-ui">step 2</a>.
      </p>
      <p>Add the Tailwind plugin to your dependencies in <code>mix.exs</code>:</p>
      <pre><code class="language-elixir">{"defp deps do\n  [\n    {:tailwind, \"~> 0.3\", runtime: Mix.env() == :dev},\n    # ...\n  ]\nend"}</code></pre>
      <p>Configure Tailwind in <code>config/config.exs</code>:</p>
      <pre><code class="language-elixir">{"config :tailwind,\n  version: \"4.1.12\",\n  my_app: [\n    args: ~w(\n      --input=assets/css/app.css\n      --output=priv/static/assets/app.css\n    ),\n    cd: Path.expand(\"..\", __DIR__)\n  ]"}</code></pre>
      <p>Add the Tailwind watcher in <code>config/dev.exs</code>:</p>
      <pre><code class="language-elixir">{"config :my_app, MyAppWeb.Endpoint,\n  watchers: [\n    tailwind: {Tailwind, :install_and_run, [:my_app, ~w(--watch)]}\n  ]"}</code></pre>
      <p>Add Tailwind to the deployment alias in <code>mix.exs</code>:</p>
      <pre><code class="language-elixir">{"defp aliases do\n  [\n    \"assets.deploy\": [\n      \"tailwind my_app --minify\",\n      \"esbuild my_app --minify\",\n      \"phx.digest\"\n    ]\n  ]\nend"}</code></pre>
      <p>Install Tailwind and fetch dependencies:</p>
      <pre><code class="language-bash">{"mix deps.get\nmix tailwind.install"}</code></pre>
      <p>Set up <code>assets/css/app.css</code>:</p>
      <pre><code class="language-css">@import "tailwindcss";</code></pre>
      <p>
        If your <code>assets/js/app.js</code> imports CSS
        (<code>import "../css/app.css"</code>), remove that line — Tailwind
        handles CSS compilation separately.
      </p>

      <h2 id="add-cinder-ui">2. Add Cinder UI</h2>
      <p>Add the dependency to your <code>mix.exs</code>:</p>
      <pre><code class="language-elixir">{"defp deps do\n  [\n    {:cinder_ui, \"~> 0.1.0\"},\n    # Optional but recommended — required for the <.icon /> component\n    {:lucide_icons, \"~> 2.0\"},\n    # ...\n  ]\nend"}</code></pre>
      <p>Fetch dependencies:</p>
      <pre><code class="language-bash">mix deps.get</code></pre>

      <h2 id="run-installer">3. Run the installer</h2>
      <p>
        Cinder UI includes a Mix task that sets up CSS, JavaScript hooks,
        and Tailwind plugins automatically:
      </p>
      <pre><code class="language-bash">mix cinder_ui.install</code></pre>
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
      <pre><code class="language-bash">mix cinder_ui.install --package-manager pnpm</code></pre>
      <p>To re-run without overwriting customized files:</p>
      <pre><code class="language-bash">mix cinder_ui.install --skip-existing</code></pre>
      <p>To only copy generated Cinder UI assets and skip patching app entry files:</p>
      <pre><code class="language-bash">mix cinder_ui.install --skip-patching</code></pre>

      <h2 id="configure-app">4. Configure your app</h2>
      <p>
        Add <code>use CinderUI</code>
        to your app's <code>html_helpers</code>
        in <code>lib/my_app_web.ex</code>:
      </p>
      <pre><code class="language-elixir">{"defp html_helpers do\n  quote do\n    use Phoenix.Component\n    use CinderUI\n    # ...\n  end\nend"}</code></pre>
      <p>Or selectively import only the modules you need:</p>
      <pre><code class="language-elixir">{"import CinderUI.Components.Actions\nimport CinderUI.Components.Forms"}</code></pre>

      <h2 id="verify">5. Start building</h2>
      <p>Start your Phoenix server:</p>
      <pre><code class="language-bash">mix phx.server</code></pre>
      <p>Try a component in any template:</p>
      <pre><code class="language-heex">&lt;.button&gt;Click me&lt;/.button&gt;</code></pre>
    </div>
    """
    |> to_html()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
