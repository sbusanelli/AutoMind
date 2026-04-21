defmodule AutomindWeb.TurboQuant.Cache do
  @moduledoc """
  TurboQuant cache for storing compression results.
  """
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Initialize cache
    {:ok, %{}}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    new_state = Map.put(state, key, value)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_cast(:clear, _state) do
    {:noreply, %{}}
  end
end
