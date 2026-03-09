defmodule DemoWeb.SiteControllerTest do
  use DemoWeb.ConnCase

  alias Demo.SiteRuntime

  test "GET / renders marketing page", %{conn: conn} do
    conn = get(conn, ~p"/")
    body = html_response(conn, 200)

    assert body =~ "Cinder UI"
    assert body =~ "Browse Component Library"
  end

  test "GET /docs renders component index", %{conn: conn} do
    conn = get(conn, ~p"/docs")
    body = html_response(conn, 200)

    assert body =~ "Component Library"
    assert body =~ "Open docs"
  end

  test "GET /docs/:id renders component page", %{conn: conn} do
    entry =
      SiteRuntime.catalog_sections()
      |> Enum.flat_map(& &1.entries)
      |> List.first()

    conn = get(conn, ~p"/docs/#{entry.id}")
    body = html_response(conn, 200)

    assert body =~ entry.id
    assert body =~ "Original shadcn/ui docs"
  end

  test "GET /docs/install renders installation guide", %{conn: conn} do
    conn = get(conn, ~p"/docs/install")
    body = html_response(conn, 200)

    assert body =~ "Installation"
    assert body =~ "mix cinder_ui.install"
    assert body =~ "use CinderUI"
  end

  test "GET /assets/site.css serves docs CSS", %{conn: conn} do
    conn = get(conn, ~p"/assets/site.css")

    assert response(conn, 200) =~ ".docs-markdown"
    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/css"
  end
end
