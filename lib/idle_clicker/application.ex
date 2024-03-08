defmodule IdleClicker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IdleClickerWeb.Telemetry,
      IdleClicker.Repo,
      {DNSCluster, query: Application.get_env(:idle_clicker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: IdleClicker.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: IdleClicker.Finch},
      # Start a worker by calling: IdleClicker.Worker.start_link(arg)
      # {IdleClicker.Worker, arg},
      # Start to serve requests, typically the last entry
      IdleClickerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IdleClicker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IdleClickerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
