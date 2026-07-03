defmodule CinderUI.Docs.StaticRenderer do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Docs.ThemeModel
  alias CinderUI.Docs.UIComponents
  alias Phoenix.HTML.Safe

  def docs_index_html(sections, opts) when is_list(sections) and is_list(opts) do
    root_prefix = Keyword.fetch!(opts, :root_prefix)

    page_shell(
      title: Keyword.fetch!(opts, :title),
      description: Keyword.fetch!(opts, :description),
      body_content:
        docs_index_body(sections, root_prefix,
          component_count: Keyword.get(opts, :component_count),
          show_count: Keyword.get(opts, :show_count, false)
        ),
      sections: sections,
      active_entry_id: nil,
      active_page: :overview,
      root_prefix: root_prefix,
      home_url: Keyword.fetch!(opts, :home_url),
      asset_prefix: Keyword.fetch!(opts, :asset_prefix),
      github_url: Keyword.fetch!(opts, :github_url),
      hex_package_url: Keyword.fetch!(opts, :hex_package_url),
      after_body_html: Keyword.get(opts, :after_body_html)
    )
  end

  def docs_component_html(entry, sections, opts) when is_list(sections) and is_list(opts) do
    root_prefix = Keyword.fetch!(opts, :root_prefix)

    page_shell(
      title: Keyword.fetch!(opts, :title),
      description: Keyword.fetch!(opts, :description),
      body_content: docs_component_body(entry, sections, root_prefix),
      sections: sections,
      active_entry_id: entry.id,
      active_page: nil,
      root_prefix: root_prefix,
      home_url: Keyword.fetch!(opts, :home_url),
      asset_prefix: Keyword.fetch!(opts, :asset_prefix),
      github_url: Keyword.fetch!(opts, :github_url),
      hex_package_url: Keyword.fetch!(opts, :hex_package_url),
      after_body_html: Keyword.get(opts, :after_body_html)
    )
  end

  def install_html(sections, opts) when is_list(sections) and is_list(opts) do
    page_shell(
      title: Keyword.fetch!(opts, :title),
      description: Keyword.fetch!(opts, :description),
      body_content: install_body(),
      sections: sections,
      active_entry_id: nil,
      active_page: :install,
      root_prefix: Keyword.fetch!(opts, :root_prefix),
      home_url: Keyword.fetch!(opts, :home_url),
      asset_prefix: Keyword.fetch!(opts, :asset_prefix),
      github_url: Keyword.fetch!(opts, :github_url),
      hex_package_url: Keyword.fetch!(opts, :hex_package_url),
      after_body_html: Keyword.get(opts, :after_body_html)
    )
  end

  def recipes_html(sections, opts) when is_list(sections) and is_list(opts) do
    page_shell(
      title: Keyword.fetch!(opts, :title),
      description: Keyword.fetch!(opts, :description),
      body_content: recipes_body(Keyword.fetch!(opts, :root_prefix)),
      sections: sections,
      active_entry_id: nil,
      active_page: :recipes,
      root_prefix: Keyword.fetch!(opts, :root_prefix),
      home_url: Keyword.fetch!(opts, :home_url),
      asset_prefix: Keyword.fetch!(opts, :asset_prefix),
      github_url: Keyword.fetch!(opts, :github_url),
      hex_package_url: Keyword.fetch!(opts, :hex_package_url),
      after_body_html: Keyword.get(opts, :after_body_html)
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
      hex_package_url: opts[:hex_package_url],
      after_body_html: opts[:after_body_html]
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
        {rendered(@after_body_html)}
      </body>
    </html>
    """
    |> to_html()
  end

  defp docs_index_body(sections, root_prefix, opts) do
    assigns = %{
      sections: sections,
      component_count: Keyword.get(opts, :component_count),
      show_count: Keyword.get(opts, :show_count, false),
      root_prefix: root_prefix
    }

    ~H"""
    <UIComponents.docs_overview_intro
      component_count={@component_count}
      show_count={@show_count}
    />

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
      />
      <p>Configure Tailwind in <code>config/config.exs</code>:</p>
      <UIComponents.docs_code_block
        source={"config :tailwind,\n  version: \"4.1.12\",\n  my_app: [\n    args: ~w(\n      --input=assets/css/app.css\n      --output=priv/static/assets/app.css\n    ),\n    cd: Path.expand(\"..\", __DIR__)\n  ]"}
        language={:elixir}
      />
      <p>Add the Tailwind watcher in <code>config/dev.exs</code>:</p>
      <UIComponents.docs_code_block
        source="config :my_app, MyAppWeb.Endpoint,
    watchers: [
    tailwind: {Tailwind, :install_and_run, [:my_app, ~w(--watch)]}
    ]"
        language={:elixir}
      />
      <p>Add Tailwind to the deployment alias in <code>mix.exs</code>:</p>
      <UIComponents.docs_code_block
        source={"defp aliases do\n  [\n    \"assets.deploy\": [\n      \"tailwind my_app --minify\",\n      \"esbuild my_app --minify\",\n      \"phx.digest\"\n    ]\n  ]\nend"}
        language={:elixir}
      />
      <p>Install Tailwind and fetch dependencies:</p>
      <UIComponents.docs_code_block
        source="mix deps.get
    mix tailwind.install"
        language={:bash}
      />
      <p>Set up <code>assets/css/app.css</code>:</p>
      <UIComponents.docs_code_block
        source={"@import \"tailwindcss\";"}
        language={:css}
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
      />
      <p>Fetch dependencies:</p>
      <UIComponents.docs_code_block
        source="mix deps.get"
        language={:bash}
      />

      <h2 id="run-installer">3. Run the installer</h2>
      <p>
        Cinder UI includes a Mix task that wires its CSS and JavaScript hooks
        into your Phoenix app:
      </p>
      <UIComponents.docs_code_block
        source="mix cinder_ui.install"
        language={:bash}
      />
      <p>This will:</p>
      <ul>
        <li>
          Update <code>assets/css/app.css</code> with:<br />
          <code>@source "../../deps/cinder_ui";</code> — so Tailwind scans component classes<br />
          <code>@import "../../deps/cinder_ui/priv/templates/cinder_ui.css";</code> — loads theme tokens and animation utilities
        </li>
        <li>
          Update <code>assets/js/app.js</code>
          to merge <code>CinderUIHooks</code>
          into your LiveView hooks
        </li>
      </ul>
      <p>
        Everything is referenced straight from <code>deps/cinder_ui</code>, so it
        stays in sync automatically whenever you upgrade the dependency. There is
        no npm package to install — the <code>tailwindcss-animate</code> animation
        utilities are inlined into Cinder UI's CSS.
      </p>
      <p>
        Prefer to wire it up by hand? Add those two lines to
        <code>assets/css/app.css</code> yourself and skip the app patching:
      </p>
      <UIComponents.docs_code_block
        source="mix cinder_ui.install --skip-patching"
        language={:bash}
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
      />
      <p>Or selectively import only the modules you need:</p>
      <UIComponents.docs_code_block
        source="import CinderUI.Components.Actions
    import CinderUI.Components.Forms"
        language={:elixir}
      />

      <h2 id="verify">5. Start building</h2>
      <p>Start your Phoenix server:</p>
      <UIComponents.docs_code_block
        source="mix phx.server"
        language={:bash}
      />
      <p>Try a component in any template:</p>
      <UIComponents.docs_code_block
        source="<.button>Click me</.button>"
        language={:heex}
      />
    </div>
    """
    |> to_html()
  end

  defp recipes_body(root_prefix) do
    assigns = %{root_prefix: root_prefix}

    ~H"""
    <UIComponents.recipes_page mode={:static} root_prefix={@root_prefix} />
    """
    |> to_html()
  end

  defp rendered(nil), do: Phoenix.HTML.raw("")
  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp theme_bootstrap_script do
    ThemeModel.bootstrap_script()
  end

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
