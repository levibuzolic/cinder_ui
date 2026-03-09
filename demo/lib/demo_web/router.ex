defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :asset do
    plug :accepts, ["*/*"]
    plug :put_secure_browser_headers
  end

  scope "/", DemoWeb do
    pipe_through :asset

    get "/assets/*path", SiteController, :asset
  end

  scope "/", DemoWeb do
    pipe_through :browser

    get "/", SiteController, :marketing
    get "/docs", SiteController, :docs
    get "/docs/install", SiteController, :install
    get "/docs/:id", SiteController, :component
  end
end
