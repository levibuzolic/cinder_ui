defmodule Mix.Tasks.Demo.Site.Export do
  @shortdoc "Exports live-rendered demo pages to dist/site"
  @moduledoc """
  Starts the demo endpoint, requests the live-rendered marketing/docs pages,
  and writes a static site bundle to `../dist/site`.

  The exported site is suitable for GitHub Pages publishing.

      cd demo && mix demo.site.export
  """

  use Mix.Task

  alias Demo.SiteRuntime

  @impl true
  def run(argv) do
    if argv != [] do
      Mix.raise("`mix demo.site.export` does not accept flags or options.")
    end

    port = 4_011
    base_url = "http://127.0.0.1:#{port}"
    output_dir = Path.expand("../dist/site", File.cwd!())

    configure_endpoint!(port)

    Mix.Task.run("compile")
    {:ok, _} = Application.ensure_all_started(:demo)

    if File.dir?(output_dir), do: File.rm_rf!(output_dir)

    write_pages!(output_dir, base_url)
    write_assets!(output_dir)

    File.write!(Path.join(output_dir, ".nojekyll"), "")

    Mix.shell().info("generated #{Path.relative_to(output_dir, File.cwd!())}")
    Mix.shell().info("open #{Path.relative_to(Path.join(output_dir, "index.html"), File.cwd!())}")
  end

  defp configure_endpoint!(port) do
    endpoint_env =
      :demo
      |> Application.get_env(DemoWeb.Endpoint, [])
      |> Keyword.merge(server: true, url: [host: "127.0.0.1", port: port, scheme: "http"])
      |> Keyword.put(:http, ip: {127, 0, 0, 1}, port: port)
      |> Keyword.delete(:live_reload)

    Application.put_env(:demo, DemoWeb.Endpoint, endpoint_env)
  end

  defp write_pages!(output_dir, base_url) do
    for path <- SiteRuntime.static_paths() do
      request_path = path_with_static_query(path)
      output_path = Path.join(output_dir, destination_path(path))
      html = fetch_html!(base_url <> request_path)

      File.mkdir_p!(Path.dirname(output_path))
      File.write!(output_path, html)
    end
  end

  defp write_assets!(output_dir) do
    assets_dir = Path.join(output_dir, "assets")
    File.mkdir_p!(assets_dir)

    File.write!(
      Path.join(assets_dir, "theme.css"),
      File.read!(SiteRuntime.asset_path("theme.css"))
    )

    File.write!(Path.join(assets_dir, "site.css"), File.read!(SiteRuntime.asset_path("site.css")))
    File.write!(Path.join(assets_dir, "static_docs.js"), SiteRuntime.docs_site_js())
  end

  defp fetch_html!(url) do
    response = Req.get!(url: url)

    case response.status do
      200 when is_binary(response.body) -> response.body
      status -> Mix.raise("export fetch failed (#{status}) for #{url}")
    end
  end

  defp path_with_static_query(path), do: path <> "?static=1"

  defp destination_path("/"), do: "index.html"
  defp destination_path("/docs/"), do: Path.join(["docs", "index.html"])
  defp destination_path("/docs/install/"), do: Path.join(["docs", "install", "index.html"])

  defp destination_path(path) do
    ["", "docs", id, ""] = String.split(path, "/")
    Path.join(["docs", id, "index.html"])
  end
end
