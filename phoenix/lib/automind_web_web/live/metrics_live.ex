defmodule AutomindWebWeb.MetricsLive do
  use AutomindWebWeb, :live_view

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Metrics")
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "metrics")
    end

    socket =
      socket
      |> assign(:metrics, %{
        cpu_usage: 45.2,
        memory_usage: 67.8,
        disk_usage: 23.4,
        network_throughput: 1250,
        response_time: 120,
        error_rate: 0.02
      })

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">System Metrics</h1>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-medium text-gray-500">CPU Usage</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @metrics.cpu_usage %>%</p>
          <div class="mt-2 bg-gray-200 rounded-full h-2">
            <div class="bg-green-600 h-2 rounded-full" style={"width: #{@metrics.cpu_usage}%"}></div>
          </div>
        </div>
        
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-medium text-gray-500">Memory Usage</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @metrics.memory_usage %>%</p>
          <div class="mt-2 bg-gray-200 rounded-full h-2">
            <div class="bg-yellow-600 h-2 rounded-full" style={"width: #{@metrics.memory_usage}%"}></div>
          </div>
        </div>
        
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-medium text-gray-500">Disk Usage</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @metrics.disk_usage %>%</p>
          <div class="mt-2 bg-gray-200 rounded-full h-2">
            <div class="bg-blue-600 h-2 rounded-full" style={"width: #{@metrics.disk_usage}%"}></div>
          </div>
        </div>
        
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-medium text-gray-500">Network Throughput</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @metrics.network_throughput %> Mbps</p>
        </div>
        
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-medium text-gray-500">Response Time</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @metrics.response_time %> ms</p>
        </div>
        
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-medium text-gray-500">Error Rate</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @metrics.error_rate * 100 %>%</p>
        </div>
      </div>
    </div>
    """
  end
end
