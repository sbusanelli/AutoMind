defmodule AutomindWebWeb.Telemetry do
  @moduledoc """
  Telemetry configuration for AutomindWeb.
  """
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, strategy: :one_for_one)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will be started automatically
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
