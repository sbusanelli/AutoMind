defmodule AutomindWebWeb.DashboardHelpers do
  @moduledoc """
  Helper functions for the dashboard LiveView.
  """

  def get_active_jobs() do
    [
      %{id: 1, name: "Document Processing", status: "active", progress: 75},
      %{id: 2, name: "AI Analysis", status: "active", progress: 45},
      %{id: 3, name: "Data Compression", status: "queued", progress: 0}
    ]
  end

  def get_latest_insights() do
    [
      %{id: 1, type: "performance", message: "System optimization detected 15% improvement", timestamp: DateTime.utc_now()},
      %{id: 2, type: "anomaly", message: "Unusual API activity pattern detected", timestamp: DateTime.utc_now()},
      %{id: 3, type: "recommendation", message: "Consider scaling up resources for peak hours", timestamp: DateTime.utc_now()}
    ]
  end

  def get_performance_metrics() do
    %{
      cpu_usage: 45.2,
      memory_usage: 67.8,
      response_time: 120,
      throughput: 1250
    }
  end

  def calculate_cost_savings() do
    %{
      monthly: 2500,
      yearly: 30000,
      percentage: 23.5
    }
  end

  def calculate_uptime() do
    99.8
  end

  def get_system_health() do
    %{
      status: "healthy",
      services: %{
        database: "connected",
        api: "operational",
        cache: "optimal"
      }
    }
  end
end
