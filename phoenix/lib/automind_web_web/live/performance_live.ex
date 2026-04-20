defmodule AutomindWebWeb.PerformanceLive do
  use AutomindWebWeb, :live_view

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Performance")
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "performance")
    end

    socket =
      socket
      |> assign(:performance_data, [
        %{time: "00:00", cpu: 45, memory: 68, response_time: 120},
        %{time: "00:05", cpu: 52, memory: 71, response_time: 135},
        %{time: "00:10", cpu: 48, memory: 69, response_time: 118},
        %{time: "00:15", cpu: 61, memory: 74, response_time: 145},
        %{time: "00:20", cpu: 55, memory: 72, response_time: 128},
        %{time: "00:25", cpu: 49, memory: 70, response_time: 122}
      ])
      |> assign(:alerts, [
        %{id: 1, type: "warning", message: "CPU usage spike detected", time: DateTime.utc_now()},
        %{id: 2, type: "info", message: "Memory usage within normal range", time: DateTime.utc_now()}
      ])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Performance Monitoring</h1>
      
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow">
          <div class="px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-medium text-gray-900">CPU Usage Trend</h2>
          </div>
          <div class="p-6">
            <div class="space-y-2">
              <%= for data <- @performance_data do %>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600"><%= data.time %></span>
                  <div class="flex items-center space-x-2">
                    <div class="w-32 bg-gray-200 rounded-full h-2">
                      <div class="bg-blue-600 h-2 rounded-full" style={"width: #{data.cpu}%"}></div>
                    </div>
                    <span class="text-sm font-medium"><%= data.cpu %>%</span>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        
        <div class="bg-white rounded-lg shadow">
          <div class="px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-medium text-gray-900">Memory Usage Trend</h2>
          </div>
          <div class="p-6">
            <div class="space-y-2">
              <%= for data <- @performance_data do %>
                <div class="flex justify-between items-center">
                  <span class="text-sm text-gray-600"><%= data.time %></span>
                  <div class="flex items-center space-x-2">
                    <div class="w-32 bg-gray-200 rounded-full h-2">
                      <div class="bg-green-600 h-2 rounded-full" style={"width: #{data.memory}%"}></div>
                    </div>
                    <span class="text-sm font-medium"><%= data.memory %>%</span>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
      
      <div class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Performance Alerts</h2>
        </div>
        <div class="p-6">
          <%= for alert <- @alerts do %>
            <div class={"mb-4 p-4 rounded-lg border-l-4 " <> 
              case alert.type do
                "warning" -> "bg-yellow-50 border-yellow-400"
                "error" -> "bg-red-50 border-red-400"
                "info" -> "bg-blue-50 border-blue-400"
                _ -> "bg-gray-50 border-gray-400"
              end}>
              <div class="flex">
                <div class="ml-3">
                  <p class="text-sm font-medium text-gray-900"><%= alert.message %></p>
                  <p class="text-xs text-gray-500 mt-1"><%= Calendar.strftime(alert.time, "%Y-%m-%d %H:%M:%S") %></p>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
