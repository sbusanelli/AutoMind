defmodule AutomindWeb.TurboQuant.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # TurboQuant HTTP client
      {AutomindWeb.TurboQuant.Client, name: AutomindWeb.TurboQuant.Client},
      # TurboQuant cache
      {AutomindWeb.TurboQuant.Cache, name: AutomindWeb.TurboQuant.Cache},
      # TurboQuant metrics collector
      {AutomindWeb.TurboQuant.Metrics, name: AutomindWeb.TurboQuant.Metrics}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
