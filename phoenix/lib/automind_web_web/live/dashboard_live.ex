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
    <div class="dashboard-container">
      <.header />
      
      <div class="metrics-grid">
        <.metric_card 
          title="Active Jobs" 
          value={@active_jobs} 
          icon="briefcase" 
          trend="+12%"
          color="blue" 
        />
        <.metric_card 
          title="AI Insights" 
          value={length(@ai_insights)} 
          icon="brain" 
          trend="+25%"
          color="purple" 
        />
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
