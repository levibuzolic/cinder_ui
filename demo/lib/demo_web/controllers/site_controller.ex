defmodule DemoWeb.SiteController do
  use DemoWeb, :controller

  alias Demo.SiteRenderer
  alias Demo.SiteRuntime

  def marketing(conn, _params) do
    render_html(conn, SiteRenderer.marketing_html())
  end

  def docs(conn, params) do
    if static_render?(params) do
      render_html(conn, SiteRenderer.docs_index_html())
    else
      render(conn, :docs_index,
        sections: SiteRuntime.catalog_sections(),
        component_count: SiteRuntime.catalog_component_count(),
        github_url: SiteRuntime.github_url(),
        hex_package_url: SiteRuntime.hex_package_url()
      )
    end
  end

  def install(conn, params) do
    if static_render?(params) do
      render_html(conn, SiteRenderer.install_html())
    else
      render(conn, :install,
        sections: SiteRuntime.catalog_sections(),
        github_url: SiteRuntime.github_url(),
        hex_package_url: SiteRuntime.hex_package_url()
      )
    end
  end

  def component(conn, %{"id" => id} = params) do
    case SiteRuntime.find_entry(id) do
      nil ->
        send_resp(conn, 404, "Not found")

      entry ->
        if static_render?(params) do
          render_html(conn, SiteRenderer.docs_component_html(entry))
        else
          render(conn, :component,
            sections: SiteRuntime.catalog_sections(),
            entry: entry,
            github_url: SiteRuntime.github_url(),
            hex_package_url: SiteRuntime.hex_package_url()
          )
        end
    end
  end

  def asset(conn, %{"path" => [name]}) do
    with path when is_binary(path) <- SiteRuntime.asset_path(name),
         true <- File.regular?(path) do
      conn
      |> put_resp_content_type(MIME.from_path(path))
      |> send_file(200, path)
    else
      _ -> send_resp(conn, 404, "Not found")
    end
  end

  def asset(conn, _params), do: send_resp(conn, 404, "Not found")

  defp static_render?(params) do
    params["static"] in ["1", "true"]
  end

  defp render_html(conn, html) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
end
