defmodule AutomindWeb.TurboQuant.Metrics do
  @moduledoc """
  TurboQuant metrics collection and reporting.
  """
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Initialize metrics tracking
    {:ok, %{
      compression_count: 0,
      total_compression_time: 0,
      average_compression_ratio: 0.0,
      last_updated: DateTime.utc_now()
    }}
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:update_metrics, new_metrics}, state) do
    updated_state = Map.merge(state, new_metrics)
    {:noreply, updated_state}
  end

  @impl true
  def handle_info(:reset_metrics, state) do
    new_state = %{
      compression_count: 0,
      total_compression_time: 0,
      average_compression_ratio: 0.0,
      last_updated: DateTime.utc_now()
    }
    {:noreply, new_state}
  end
end
