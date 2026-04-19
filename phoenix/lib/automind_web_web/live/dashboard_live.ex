defmodule AutomindWebWeb.DashboardLive do
  use AutomindWebWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "ai_insights")
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "job_updates")
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "performance_metrics")
      
      # Start periodic updates
      Process.send_after(self(), :update_metrics, 1000)
    end

    socket =
      socket
      |> assign(:page_title, "AutoMind Dashboard")
      |> assign(:active_jobs, get_active_jobs())
      |> assign(:ai_insights, get_latest_insights())
      |> assign(:performance_metrics, get_performance_metrics())
      |> assign(:cost_savings, calculate_cost_savings())
      |> assign(:uptime_percentage, calculate_uptime())
      |> assign(:system_health, get_system_health())

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
        <.metric_card 
          title="Cost Savings" 
          value={"$#{@cost_savings}/mo"} 
          icon="dollar-sign" 
          trend="+18%"
          color="green" 
        />
        <.metric_card 
          title="Uptime" 
          value={"#{@uptime_percentage}%"} 
          icon="activity" 
          trend="+0.3%"
          color="emerald" 
        />
      </div>

      <div class="dashboard-grid">
        <.ai_insights_panel insights={@ai_insights} />
        <.operations_panel />
        <.performance_panel metrics={@performance_metrics} />
        <.system_health_panel health={@system_health} />
      </div>

      <.live_chat_component />
    </div>
    """
  end

  @impl true
  def handle_info({:ai_insight, insight}, socket) do
    updated_insights = [insight | socket.assigns.ai_insights] |> Enum.take(10)
    {:noreply, assign(socket, :ai_insights, updated_insights)}
  end

  @impl true
  def handle_info({:job_update, job}, socket) do
    {:noreply, assign(socket, :active_jobs, update_job_count(socket.assigns.active_jobs, job))}
  end

  @impl true
  def handle_info({:performance_update, metrics}, socket) do
    {:noreply, assign(socket, :performance_metrics, metrics)}
  end

  @impl true
  def handle_info(:update_metrics, socket) do
    Process.send_after(self(), :update_metrics, 5000) # Update every 5 seconds
    
    socket =
      socket
      |> assign(:active_jobs, get_active_jobs())
      |> assign(:performance_metrics, get_performance_metrics())
      |> assign(:cost_savings, calculate_cost_savings())
      |> assign(:uptime_percentage, calculate_uptime())
      |> assign(:system_health, get_system_health())

    {:noreply, socket}
  end

  @impl true
  def handle_event("refresh_insights", _params, socket) do
    {:noreply, assign(socket, :ai_insights, get_latest_insights())}
  end

  @impl true
  def handle_event("optimize_now", _params, socket) do
    # Trigger AI optimization
    Task.start(fn ->
      AutomindWeb.AI.Operations.optimize_system()
      Phoenix.PubSub.broadcast(AutomindWeb.PubSub, "ai_insights", {:ai_insight, %{
        type: "optimization",
        message: "System optimization triggered",
        timestamp: DateTime.utc_now(),
        impact: "Expected 15% performance improvement"
      }})
    end)

    {:noreply, put_flash(socket, :info, "Optimization started...")}
  end

  # Component functions
  defp header(assigns) do
    ~H"""
    <header class="dashboard-header">
      <div class="header-content">
        <h1 class="text-3xl font-bold text-gray-900">AutoMind Dashboard</h1>
        <p class="text-gray-600 mt-2">Real-time AI-powered operations intelligence</p>
      </div>
      <div class="header-actions">
        <button 
          phx-click="optimize_now" 
          class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition-colors"
        >
          <.icon name="zap" class="inline-block w-4 h-4 mr-2" />
          Optimize Now
        </button>
        <button 
          phx-click="refresh_insights" 
          class="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <.icon name="refresh-cw" class="inline-block w-4 h-4 mr-2" />
          Refresh
        </button>
      </div>
    </header>
    """
  end

  defp metric_card(assigns) do
    ~H"""
    <div class={"metric-card metric-card--#{@color}"}>
      <div class="metric-card__header">
        <.icon name={@icon} class="w-6 h-6" />
        <span class="metric-card__title"><%= @title %></span>
      </div>
      <div class="metric-card__value">
        <span class="text-2xl font-bold"><%= @value %></span>
        <span class="metric-card__trend text-sm text-green-600"><%= @trend %></span>
      </div>
    </div>
    """
  end

  defp ai_insights_panel(assigns) do
    ~H"""
    <div class="panel panel--purple">
      <div class="panel__header">
        <h2 class="text-xl font-semibold">AI Insights</h2>
        <.icon name="brain" class="w-5 h-5" />
      </div>
      <div class="panel__content">
        <%= if @insights == [] do %>
          <div class="text-center py-8 text-gray-500">
            <.icon name="inbox" class="w-12 h-12 mx-auto mb-4" />
            <p>No AI insights available</p>
            <p class="text-sm mt-2">Insights will appear as the system analyzes your operations</p>
          </div>
        <% else %>
          <div class="insights-list">
            <%= for insight <- @insights do %>
              <div class="insight-item">
                <div class="insight-item__header">
                  <span class={"insight-type insight-type--#{insight.type}"}>
                    <%= String.capitalize(insight.type) %>
                  </span>
                  <span class="insight-time">
                    <%= format_timestamp(insight.timestamp) %>
                  </span>
                </div>
                <div class="insight-item__content">
                  <p><%= insight.message %></p>
                  <%= if insight.impact do %>
                    <p class="text-sm text-gray-600 mt-1">
                      <strong>Impact:</strong> <%= insight.impact %>
                    </p>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp operations_panel(assigns) do
    ~H"""
    <div class="panel">
      <div class="panel__header">
        <h2 class="text-xl font-semibold">Operations</h2>
        <.icon name="settings" class="w-5 h-5" />
      </div>
      <div class="panel__content">
        <div class="operations-grid">
          <div class="operation-item">
            <.icon name="cpu" class="w-8 h-8 text-blue-500" />
            <div>
              <h3 class="font-semibold">CPU Usage</h3>
              <p class="text-2xl font-bold">42%</p>
              <p class="text-sm text-gray-600">Normal operation</p>
            </div>
          </div>
          <div class="operation-item">
            <.icon name="hard-drive" class="w-8 h-8 text-green-500" />
            <div>
              <h3 class="font-semibold">Memory</h3>
              <p class="text-2xl font-bold">68%</p>
              <p class="text-sm text-gray-600">Optimal range</p>
            </div>
          </div>
          <div class="operation-item">
            <.icon name="database" class="w-8 h-8 text-purple-500" />
            <div>
              <h3 class="font-semibold">Database</h3>
              <p class="text-2xl font-bold">12ms</p>
              <p class="text-sm text-gray-600">Avg response time</p>
            </div>
          </div>
          <div class="operation-item">
            <.icon name="wifi" class="w-8 h-8 text-orange-500" />
            <div>
              <h3 class="font-semibold">Network</h3>
              <p class="text-2xl font-bold">1.2GB/s</p>
              <p class="text-sm text-gray-600">Throughput</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp performance_panel(assigns) do
    ~H"""
    <div class="panel">
      <div class="panel__header">
        <h2 class="text-xl font-semibold">Performance Metrics</h2>
        <.icon name="trending-up" class="w-5 h-5" />
      </div>
      <div class="panel__content">
        <div class="performance-chart">
          <div class="chart-header">
            <h3>Response Time (ms)</h3>
            <span class="chart-value"><%= @metrics.avg_response_time %></span>
          </div>
          <div class="chart-bars">
            <%= for {value, index} <- Enum.with_index(@metrics.response_times) do %>
              <div 
                class={"chart-bar #{if index == length(@metrics.response_times) - 1, do: "chart-bar--active"}"}
                style={"height: #{value * 2}%"}
                title={"#{value}ms"}
              ></div>
            <% end %>
          </div>
        </div>
        
        <div class="performance-stats">
          <div class="stat-item">
            <span class="stat-label">Success Rate</span>
            <span class="stat-value"><%= @metrics.success_rate %>%</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Requests/sec</span>
            <span class="stat-value"><%= @metrics.requests_per_second %></span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Error Rate</span>
            <span class="stat-value"><%= @metrics.error_rate %>%</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp system_health_panel(assigns) do
    ~H"""
    <div class="panel">
      <div class="panel__header">
        <h2 class="text-xl font-semibold">System Health</h2>
        <.icon name="heart" class="w-5 h-5" />
      </div>
      <div class="panel__content">
        <div class="health-indicators">
          <%= for service <- @health.services do %>
            <div class="health-item">
              <div class={"health-status health-status--#{service.status}"}>
                <.icon name="circle" class="w-3 h-3" />
              </div>
              <div class="health-info">
                <span class="health-name"><%= service.name %></span>
                <span class="health-status-text"><%= service.status %></span>
              </div>
            </div>
          <% end %>
        </div>
        
        <div class="health-summary">
          <div class="summary-item">
            <span class="summary-label">Overall Health</span>
            <span class={"summary-value summary-value--#{@health.overall}"}>
              <%= String.capitalize(@health.overall) %>
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Last Check</span>
            <span class="summary-value">
              <%= format_timestamp(@health.last_check) %>
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp live_chat_component(assigns) do
    ~H"""
    <div class="chat-widget">
      <div class="chat-header">
        <h3>AI Assistant</h3>
        <.icon name="message-circle" class="w-5 h-5" />
      </div>
      <div class="chat-content">
        <div class="chat-messages">
          <div class="message message--ai">
            <p>Hello! I'm your AI operations assistant. Ask me anything about your system performance, optimization opportunities, or operational insights.</p>
          </div>
        </div>
        <div class="chat-input">
          <input 
            type="text" 
            placeholder="Ask about your operations..." 
            class="chat-input-field"
          />
          <button class="chat-send-btn">
            <.icon name="send" class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp icon(assigns) do
    ~H"""
    <svg class={@class} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <%= case @name do %>
        <% "brain" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
        <% "briefcase" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A2.25 2.25 0 0118.75 15.5H5.25A2.25 2.25 0 013 13.255V9A2.25 2.25 0 015.25 6.75h10.5A2.25 2.25 0 0118 9v4.255z M16.5 3.75v4.5m-11-4.5v4.5" />
        <% "dollar-sign" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
        <% "activity" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        <% "zap" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        <% "refresh-cw" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        <% "settings" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
        <% "cpu" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
        <% "hard-drive" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4" />
        <% "database" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" />
        <% "wifi" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.111 16.404a5.5 5.5 0 017.778 0M12 20h.01m-7.08-7.071c3.904-3.905 10.236-3.905 14.141 0M1.394 9.393c5.857-5.857 15.355-5.857 21.213 0" />
        <% "trending-up" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
        <% "heart" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        <% "circle" -> %>
          <circle cx="12" cy="12" r="10" />
        <% "message-circle" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        <% "send" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
        <% "inbox" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
      <% end %>
    </svg>
    """
  end

  # Helper functions
  defp get_active_jobs do
    # Simulate getting active jobs from Node.js backend
    :rand.uniform(50) + 10
  end

  defp get_latest_insights do
    # Simulate AI insights
    [
      %{
        type: "optimization",
        message: "Database queries can be optimized by adding indexes to user_id and created_at columns",
        timestamp: DateTime.add(DateTime.utc_now(), -300, :second),
        impact: "Expected 40% query performance improvement"
      },
      %{
        type: "prediction",
        message: "3 CI jobs likely to fail tomorrow due to memory constraints",
        timestamp: DateTime.add(DateTime.utc_now(), -600, :second),
        impact: "Preventive action can save 2 hours of downtime"
      },
      %{
        type: "anomaly",
        message: "Unusual spike in API response times detected in payment service",
        timestamp: DateTime.add(DateTime.utc_now(), -900, :second),
        impact: "Investigation recommended to prevent customer impact"
      }
    ]
  end

  defp get_performance_metrics do
    %{
      avg_response_time: 45,
      success_rate: 99.8,
      requests_per_second: 1247,
      error_rate: 0.2,
      response_times: [23, 45, 67, 34, 56, 78, 45, 23, 67, 45]
    }
  end

  defp calculate_cost_savings do
    # Simulate cost savings calculation
    :rand.uniform(5000) + 15000
  end

  defp calculate_uptime do
    # Simulate uptime calculation
    99.8
  end

  defp get_system_health do
    %{
      overall: "healthy",
      last_check: DateTime.utc_now(),
      services: [
        %{name: "API Gateway", status: "healthy"},
        %{name: "Database", status: "healthy"},
        %{name: "Redis Cache", status: "healthy"},
        %{name: "TurboQuant", status: "healthy"},
        %{name: "AI Engine", status: "healthy"}
      ]
    }
  end

  defp update_job_count(current_count, job) do
    case job.status do
      "started" -> current_count + 1
      "completed" -> current_count - 1
      "failed" -> current_count - 1
      _ -> current_count
    end
  end

  defp format_timestamp(datetime) do
    DateTime.to_string(datetime)
  end
end
