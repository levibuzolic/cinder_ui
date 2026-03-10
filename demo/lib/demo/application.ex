defmodule Demo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {DNSCluster, query: Application.get_env(:demo, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Demo.PubSub},
        if(Application.get_env(:demo, DemoWeb.Endpoint)[:code_reloader],
          do: Demo.CatalogReloader
        ),
        DemoWeb.Endpoint
      ]
      |> Enum.reject(&is_nil/1)

    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
