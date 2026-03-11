defmodule Mix.Tasks.CinderUi.Docs.Build do
  @shortdoc "Builds the unified static Cinder UI site (marketing + docs)"
  @moduledoc """
  Builds a unified static Cinder UI site.

  The generated output includes:

  - `index.html` marketing/developer landing page
  - static component docs under `docs/`

  Output can be deployed to any static host (GitHub Pages, Netlify, S3, etc)
  without running Phoenix/Elixir on the server.

  ## Examples

      mix cinder_ui.docs.build
  """

  use Mix.Task
  use Phoenix.Component

  alias CinderUI.Docs.Catalog
  alias CinderUI.Docs.UIComponents
  alias CinderUI.Site.Marketing
  alias Phoenix.HTML.Safe

  @impl true
  def run(argv) do
    if argv != [] do
      Mix.raise("`mix cinder_ui.docs.build` does not accept flags or options.")
    end

    output_dir = Path.expand("dist/site", File.cwd!())
    project = Mix.Project.config()
    github_url = to_string(project[:source_url] || "")
    hex_package_url = "https://hex.pm/packages/cinder_ui"
    hexdocs_url = "https://hexdocs.pm/cinder_ui"
    docs_output_dir = Path.join(output_dir, "docs")
    home_url = "../"

    if File.dir?(output_dir), do: File.rm_rf!(output_dir)

    assets_dir = Path.join(docs_output_dir, "assets")
    File.mkdir_p!(assets_dir)
    build_theme_css!(assets_dir)

    sections = Catalog.sections()
    entries = Enum.flat_map(sections, & &1.entries)

    File.write!(
      Path.join(docs_output_dir, "index.html"),
      overview_page_html(sections, home_url, github_url, hex_package_url)
    )

    Enum.each(entries, fn entry ->
      output_path = Path.join(docs_output_dir, entry.docs_path)
      File.mkdir_p!(Path.dirname(output_path))

      File.write!(
        output_path,
        component_page_html(entry, sections, home_url, github_url, hex_package_url)
      )
    end)

    File.write!(Path.join(assets_dir, "static_docs.js"), site_js())
    File.write!(Path.join(assets_dir, "site.css"), site_css())

    Marketing.write_marketing_index!(output_dir, %{
      github_url: github_url,
      hex_url: hex_package_url,
      hexdocs_url: hexdocs_url,
      component_count: length(entries),
      docs_path: "./docs/",
      theme_css_path: "./docs/assets/theme.css",
      site_css_path: "./docs/assets/site.css"
    })

    Mix.shell().info("generated #{relative(output_dir)}")
    Mix.shell().info("entries: #{Catalog.entry_count()}")
    Mix.shell().info("open #{relative(Path.join(output_dir, "index.html"))} in a browser")
    Mix.shell().info("open #{relative(Path.join(docs_output_dir, "index.html"))} for docs index")
  end

  defp overview_page_html(sections, home_url, github_url, hex_package_url) do
    page_shell(
      title: "Cinder UI Docs",
      description: "Static component docs for Cinder UI",
      body_content: overview_body_html(sections),
      asset_prefix: ".",
      sections: sections,
      root_prefix: ".",
      active_entry_id: nil,
      active_page: :overview,
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp component_page_html(entry, sections, home_url, github_url, hex_package_url) do
    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: component_body_html(entry, sections),
      asset_prefix: "..",
      sections: sections,
      root_prefix: "..",
      active_entry_id: entry.id,
      active_page: nil,
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp page_shell(opts) do
    assigns = %{
      title: opts[:title],
      description: opts[:description],
      body_content: opts[:body_content],
      asset_prefix: opts[:asset_prefix],
      sections: opts[:sections],
      root_prefix: opts[:root_prefix],
      active_entry_id: opts[:active_entry_id],
      active_page: opts[:active_page],
      home_url: opts[:home_url],
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
        {rendered(docs_speculation_rules_html())}
      </body>
    </html>
    """
    |> to_html()
  end

  defp overview_body_html(sections) do
    assigns = %{sections: sections}

    ~H"""
    <UIComponents.docs_overview_intro />

    <UIComponents.docs_overview_sections sections={@sections} mode={:static} root_prefix="." />
    """
    |> to_html()
  end

  defp component_body_html(entry, sections) do
    assigns = %{entry: entry, sections: sections}

    ~H"""
    <UIComponents.docs_component_detail
      entry={@entry}
      sections={@sections}
      mode={:static}
      root_prefix=".."
    />
    """
    |> to_html()
  end

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp site_js do
    docs_asset!("static_docs.js") <> ";\n"
  end

  defp site_css do
    site_asset!("site.css")
  end

  defp build_theme_css!(assets_dir) do
    docs_assets_dir = Path.join([File.cwd!(), "dev", "assets", "docs"])
    ensure_npm_available!()
    ensure_docs_tailwind_deps!(docs_assets_dir)

    output_path = Path.join(assets_dir, "theme.css")
    node_modules_path = Path.join(docs_assets_dir, "node_modules")

    run_cmd!("npm", ["exec", "--", "tailwindcss", "--input=theme.css", "--output=#{output_path}"],
      cd: docs_assets_dir,
      env: [{"NODE_PATH", node_modules_path}]
    )
  end

  defp ensure_npm_available! do
    cond do
      is_nil(System.find_executable("node")) ->
        Mix.raise("node is required to build docs CSS. Please install/activate Node.js.")

      is_nil(System.find_executable("npm")) ->
        Mix.raise("npm is required to build docs CSS. Please install/activate npm.")

      true ->
        :ok
    end
  end

  defp ensure_docs_tailwind_deps!(docs_assets_dir) do
    node_modules_dir = Path.join(docs_assets_dir, "node_modules")

    if File.dir?(node_modules_dir) do
      :ok
    else
      Mix.shell().info("installing docs CSS dependencies (dev/assets/docs)")

      run_cmd!("npm", ["install", "--no-audit", "--no-fund"], cd: docs_assets_dir)
    end
  end

  defp run_cmd!(command, args, opts) do
    {output, status} = System.cmd(command, args, Keyword.put(opts, :stderr_to_stdout, true))

    if status != 0 do
      Mix.raise("""
      command failed: #{command} #{Enum.join(args, " ")}
      #{output}
      """)
    end
  end

  defp docs_speculation_rules_html do
    template!("docs_speculation_rules.html.eex")
    |> EEx.eval_string([])
  end

  defp docs_asset!(name) do
    Path.join([File.cwd!(), "dev", "assets", "docs", name])
    |> File.read!()
  end

  defp site_asset!(name) do
    Path.join([File.cwd!(), "dev", "assets", "site", name])
    |> File.read!()
  end

  defp template!(name) do
    Path.join([File.cwd!(), "priv", "site_templates", name])
    |> File.read!()
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
