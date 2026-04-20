defmodule AutomindWebWeb.DashboardLive do
  use AutomindWebWeb, :live_view
  import AutomindWebWeb.DashboardComponents

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "ai_insights")
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "job_updates")
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "performance_metrics")
    end

    socket =
      socket
      |> assign(:page_title, "AutoMind Dashboard")
      |> assign(:active_jobs, [
        %{id: 1, name: "Document Processing", status: "active", progress: 75},
        %{id: 2, name: "AI Analysis", status: "active", progress: 45},
        %{id: 3, name: "Data Compression", status: "queued", progress: 0}
      ])
      |> assign(:ai_insights, [
        %{id: 1, type: "performance", message: "System optimization detected 15% improvement", timestamp: DateTime.utc_now()},
        %{id: 2, type: "anomaly", message: "Unusual API activity pattern detected", timestamp: DateTime.utc_now()},
        %{id: 3, type: "recommendation", message: "Consider scaling up resources for peak hours", timestamp: DateTime.utc_now()}
      ])
      |> assign(:performance_metrics, %{
        cpu_usage: 45.2,
        memory_usage: 67.8,
        response_time: 120,
        throughput: 1250
      })
      |> assign(:cost_savings, %{
        monthly: 2500,
        yearly: 30000,
        percentage: 23.5
      })
      |> assign(:uptime_percentage, 99.8)
      |> assign(:system_health, %{
        status: "healthy",
        services: %{
          database: "connected",
          api: "operational",
          cache: "optimal"
        }
      })

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">AutoMind Dashboard</h1>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-blue-50 border-l-4 border-blue-200 rounded-lg p-6">
          <h3 class="text-sm font-medium text-gray-900">Active Jobs</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= length(@active_jobs) %></p>
          <p class="text-sm text-blue-600">2 running</p>
        </div>
        
        <div class="bg-green-50 border-l-4 border-green-200 rounded-lg p-6">
          <h3 class="text-sm font-medium text-gray-900">System Health</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @system_health.status %></p>
          <p class="text-sm text-green-600">All services operational</p>
        </div>
        
        <div class="bg-purple-50 border-l-4 border-purple-200 rounded-lg p-6">
          <h3 class="text-sm font-medium text-gray-900">Uptime</h3>
          <p class="text-2xl font-semibold text-gray-900"><%= @uptime_percentage %>%</p>
          <p class="text-sm text-purple-600">Last 30 days</p>
        </div>
        
        <div class="bg-yellow-50 border-l-4 border-yellow-200 rounded-lg p-6">
          <h3 class="text-sm font-medium text-gray-900">Cost Savings</h3>
          <p class="text-2xl font-semibold text-gray-900">$<%= @cost_savings.monthly %></p>
          <p class="text-sm text-yellow-600"><%= @cost_savings.percentage %>% vs baseline</p>
        </div>
      </div>
      
      <div class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">AI Insights</h2>
        </div>
        <div class="p-6">
          <%= for insight <- @ai_insights do %>
            <div class="mb-4 p-4 bg-gray-50 rounded-lg border-l-4 border-blue-500">
              <div class="flex items-center">
                <div class={"w-3 h-3 rounded-full " <> case insight.type do
                  "performance" -> "bg-green-500"
                  "anomaly" -> "bg-red-500"
                  "recommendation" -> "bg-yellow-500"
                  _ -> "bg-gray-500"
                end}></div>
                <div class="ml-3">
                  <p class="text-sm font-medium text-gray-900"><%= insight.message %></p>
                  <p class="text-xs text-gray-500"><%= insight.timestamp %></p>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(:update_metrics, socket) do
    {:noreply, 
      socket
      |> assign(:active_jobs, get_active_jobs())
      |> assign(:ai_insights, get_latest_insights())
      |> assign(:performance_metrics, get_performance_metrics())
    }
  end

  # Helper functions
  defp get_active_jobs do
    [
      %{id: 1, name: "Document Processing", status: "active", progress: 75},
      %{id: 2, name: "AI Analysis", status: "active", progress: 45},
      %{id: 3, name: "Data Compression", status: "queued", progress: 0}
    ]
  end

  defp get_latest_insights do
    [
      %{id: 1, type: "performance", message: "System optimization detected 15% improvement", timestamp: DateTime.utc_now()},
      %{id: 2, type: "anomaly", message: "Unusual API activity pattern detected", timestamp: DateTime.utc_now()},
      %{id: 3, type: "recommendation", message: "Consider scaling up resources for peak hours", timestamp: DateTime.utc_now()}
    ]
  end

  defp get_performance_metrics do
    %{
      cpu_usage: 45.2,
      memory_usage: 67.8,
      response_time: 120,
      throughput: 1250
    }
  end
end
