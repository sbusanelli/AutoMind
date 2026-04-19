defmodule AutomindWeb.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AutomindWeb.Repo,
      # Start the Telemetry supervisor
      AutomindWebWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AutomindWeb.PubSub, adapter: Phoenix.PubSub.Redis},
      # Start Finch
      {Finch, name: AutomindWeb.Finch},
      # Start the Endpoint (http/https)
      AutomindWebWeb.Endpoint,
      # Start Redis connection
      {Redix, name: AutomindWeb.Redis},
      # Start AI Operations supervisor
      AutomindWeb.AI.OperationsSupervisor,
      # Start TurboQuant integration
      AutomindWeb.TurboQuant.Supervisor
    ]

    opts = [strategy: :one_for_one, name: AutomindWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AutomindWebWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @impl true
  def config_change(changed, _new, removed) do
    AutomindWebWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
