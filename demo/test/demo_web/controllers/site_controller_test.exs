defmodule DemoWeb.SiteControllerTest do
  use DemoWeb.ConnCase

  alias Demo.SiteRuntime

  test "GET / renders marketing page", %{conn: conn} do
    conn = get(conn, ~p"/")
    body = html_response(conn, 200)

    assert body =~ "Cinder UI"
    assert body =~ "Explore Components"
    assert body =~ "Forge beautiful interfaces with Phoenix"
    version = to_string(Application.spec(:cinder_ui, :vsn))
    assert body =~ "v#{version}"
    assert body =~ "~&gt; #{version}"
  end

  test "GET /docs renders component index", %{conn: conn} do
    conn = get(conn, ~p"/docs")
    body = html_response(conn, 200)

    assert body =~ "Component Library"
    assert body =~ "Open docs"
    assert body =~ "data-component-runtime"
    assert body =~ "Server-rendered"
  end

  test "GET /docs?static=1 renders static component index", %{conn: conn} do
    conn = get(conn, ~p"/docs?static=1")
    body = html_response(conn, 200)

    assert body =~ "<!doctype html>"
    assert body =~ "Component Library"
    assert body =~ "data-testid=\"component-count\""
    assert body =~ ~s(href="../")
    assert body =~ ~s(src="../assets/static_docs.js")
  end

  test "GET /docs/:id renders component page", %{conn: conn} do
    entry =
      SiteRuntime.catalog_sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(&(&1.runtime.kind == :progressive))

    conn = get(conn, ~p"/docs/#{entry.id}")
    body = html_response(conn, 200)

    assert body =~ entry.id
    assert body =~ "Original shadcn/ui docs"
    assert body =~ "data-runtime-kind=\"progressive\""
    assert body =~ entry.runtime.summary
  end

  test "GET /docs/install renders installation guide", %{conn: conn} do
    conn = get(conn, ~p"/docs/install")
    body = html_response(conn, 200)

    assert body =~ "Installation"
    assert body =~ "code-highlight"
    assert body =~ "tok-keyword"
  end

  test "component pages expose the same preview metadata in live and static HTML", %{conn: conn} do
    for path <- ["/docs/layout-card_title", "/docs/layout-card_title?static=1"] do
      body = conn |> get(path) |> html_response(200)
      assert body =~ ~s(property="og:title" content="Layout.card_title · Cinder UI")
      assert body =~ ~s(property="og:image" content=")
      assert body =~ "/assets/social/layout-card_title.png"
      assert body =~ ~s(name="twitter:card" content="summary_large_image")
      refute body =~ "127.0.0.1:4011"
    end
  end

  test "serves preview PNGs and returns 404 for unknown components", %{conn: conn} do
    image_conn = get(conn, "/assets/social/layout-card_title.png")
    assert get_resp_header(image_conn, "content-type") == ["image/png"]
    assert response(image_conn, 200) =~ <<137, "PNG\r\n", 26, "\n">>
    assert conn |> get("/assets/social/not-a-component.png") |> response(404)
  end

  test "GET /docs/recipes renders composed recipe examples", %{conn: conn} do
    conn = get(conn, ~p"/docs/recipes")
    body = html_response(conn, 200)

    assert body =~ "Recipes"
    assert body =~ "Auth form"
    assert body =~ "Settings page"
    assert body =~ "Admin shell"
    assert body =~ ~s(data-copy-template="recipe-auth-form")
  end

  test "GET /assets/site.css serves docs CSS", %{conn: conn} do
    conn = get(conn, ~p"/assets/site.css")

    assert response(conn, 200) =~ ".docs-markdown"
    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/css"
  end
end
