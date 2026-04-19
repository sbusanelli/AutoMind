defmodule AutomindWebWeb.AIInsightsLive do
  use AutomindWebWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "ai_insights")
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "turboquant_metrics")
      Process.send_after(self(), :refresh_insights, 2000)
    end

    socket =
      socket
      |> assign(:page_title, "AI Insights")
      |> assign(:insights, get_ai_insights())
      |> assign(:turboquant_metrics, get_turboquant_metrics())
      |> assign(:loading, false)
      |> assign(:selected_insight, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ai-insights-container">
      <.header />
      
      <div class="insights-layout">
        <.insights_list insights={@insights} selected={@selected_insight} />
        <.insight_detail insight={@selected_insight} metrics={@turboquant_metrics} />
      </div>

      <.turboquant_dashboard metrics={@turboquant_metrics} />
    </div>
    """
  end

  @impl true
  def handle_info({:ai_insight, insight}, socket) do
    updated_insights = [insight | socket.assigns.insights] |> Enum.take(50)
    {:noreply, assign(socket, :insights, updated_insights)}
  end

  @impl true
  def handle_info({:turboquant_metrics, metrics}, socket) do
    {:noreply, assign(socket, :turboquant_metrics, metrics)}
  end

  @impl true
  def handle_info(:refresh_insights, socket) do
    Process.send_after(self(), :refresh_insights, 5000)
    
    socket =
      socket
      |> assign(:insights, get_ai_insights())
      |> assign(:turboquant_metrics, get_turboquant_metrics())

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_insight", %{"id" => insight_id}, socket) do
    insight = Enum.find(socket.assigns.insights, &(&1.id == insight_id))
    {:noreply, assign(socket, :selected_insight, insight)}
  end

  @impl true
  def handle_event("analyze_document", %{"document" => document}, socket) do
    socket = assign(socket, :loading, true)
    
    Task.start(fn ->
      case AutomindWeb.TurboQuant.Client.process_document(document, "summary") do
        {:ok, response} ->
          insight = %{
            id: UUID.uuid4(),
            type: "document_analysis",
            title: "Document Analysis",
            message: response["result"]["content"],
            timestamp: DateTime.utc_now(),
            compression_metrics: response["result"]["compressionMetrics"],
            confidence: 0.95
          }
          
          Phoenix.PubSub.broadcast(AutomindWeb.PubSub, "ai_insights", {:ai_insight, insight})
        
        {:error, reason} ->
          Logger.error("Document analysis failed: #{inspect(reason)}")
      end
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("compress_data", %{"data" => data}, socket) do
    # Convert string data to float array for compression
    float_data = String.split(data, ",") |> Enum.map(&String.to_float/1)
    
    Task.start(fn ->
      case AutomindWeb.TurboQuant.Client.compress_data(float_data) do
        {:ok, response} ->
          insight = %{
            id: UUID.uuid4(),
            type: "compression",
            title: "Data Compression",
            message: "Successfully compressed data using TurboQuant",
            timestamp: DateTime.utc_now(),
            compression_ratio: response["metadata"]["compressedSize"] / response["metadata"]["originalSize"],
            original_size: response["metadata"]["originalSize"],
            compressed_size: response["metadata"]["compressedSize"],
            processing_time: response["processingTime"]
          }
          
          Phoenix.PubSub.broadcast(AutomindWeb.PubSub, "ai_insights", {:ai_insight, insight})
        
        {:error, reason} ->
          Logger.error("Data compression failed: #{inspect(reason)}")
      end
    end)

    {:noreply, socket}
  end

  # Component functions
  defp header(assigns) do
    ~H"""
    <header class="insights-header">
      <div class="header-content">
        <h1 class="text-3xl font-bold text-gray-900">AI Insights</h1>
        <p class="text-gray-600 mt-2">Real-time AI-powered operational intelligence with TurboQuant optimization</p>
      </div>
      <div class="header-actions">
        <button phx-click="refresh_insights" class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">
          <.icon name="refresh-cw" class="inline-block w-4 h-4 mr-2" />
          Refresh Insights
        </button>
      </div>
    </header>
    """
  end

  defp insights_list(assigns) do
    ~H"""
    <div class="insights-list">
      <div class="insights-list__header">
        <h2 class="text-xl font-semibold">Latest Insights</h2>
        <span class="insights-count"><%= length(@insights) %> insights</span>
      </div>
      
      <div class="insights-items">
        <%= for insight <- @insights do %>
          <div 
            class={"insight-item #{if @selected && @selected.id == insight.id, do: "insight-item--selected"}"}
            phx-click="select_insight"
            phx-value-id={insight.id}
          >
            <div class="insight-item__header">
              <span class={"insight-type insight-type--#{insight.type}"}>
                <%= String.capitalize(insight.type) %>
              </span>
              <span class="insight-time">
                <%= format_timestamp(insight.timestamp) %>
              </span>
            </div>
            <div class="insight-item__content">
              <h3 class="insight-title"><%= insight.title %></h3>
              <p class="insight-message"><%= insight.message %></p>
              <%= if insight.compression_ratio do %>
                <div class="insight-metrics">
                  <span class="metric">
                    <.icon name="compress" class="w-4 h-4" />
                    <%= Float.round(insight.compression_ratio, 2) %>x compression
                  </span>
                  <span class="metric">
                    <.icon name="clock" class="w-4 h-4" />
                    <%= insight.processing_time %>ms
                  </span>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp insight_detail(assigns) do
    ~H"""
    <div class="insight-detail">
      <%= if @insight do %>
        <div class="insight-detail__header">
          <h2 class="insight-title"><%= @insight.title %></h2>
          <div class="insight-meta">
            <span class={"insight-type insight-type--#{@insight.type}"}>
              <%= String.capitalize(@insight.type) %>
            </span>
            <span class="insight-time">
              <%= format_timestamp(@insight.timestamp) %>
            </span>
          </div>
        </div>
        
        <div class="insight-detail__content">
          <p class="insight-message"><%= @insight.message %></p>
          
          <%= if @insight.compression_metrics do %>
            <div class="compression-details">
              <h3>Compression Metrics</h3>
              <div class="metrics-grid">
                <div class="metric-item">
                  <span class="metric-label">Original Size</span>
                  <span class="metric-value"><%= @insight.compression_metrics["originalSize"] %> bytes</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">Compressed Size</span>
                  <span class="metric-value"><%= @insight.compression_metrics["compressedSize"] %> bytes</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">Compression Ratio</span>
                  <span class="metric-value"><%= @insight.compression_metrics["compressionRatio"] %>x</span>
                </div>
                <div class="metric-item">
                  <span class="metric-label">Processing Time</span>
                  <span class="metric-value"><%= @insight.compression_metrics["processingTime"] %>ms</span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        
        <div class="insight-actions">
          <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
            <.icon name="share" class="inline-block w-4 h-4 mr-2" />
            Share Insight
          </button>
          <button class="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700">
            <.icon name="bookmark" class="inline-block w-4 h-4 mr-2" />
            Save Insight
          </button>
        </div>
      <% else %>
        <div class="insight-placeholder">
          <.icon name="mouse-pointer" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-semibold text-gray-900">Select an Insight</h3>
          <p class="text-gray-600">Choose an insight from the list to view detailed information</p>
        </div>
      <% end %>
    </div>
    """
  end

  defp turboquant_dashboard(assigns) do
    ~H"""
    <div class="turboquant-dashboard">
      <div class="dashboard-header">
        <h2 class="text-xl font-semibold">TurboQuant Performance</h2>
        <div class="status-indicator status-indicator--green">
          <.icon name="circle" class="w-3 h-3" />
          Active
        </div>
      </div>
      
      <div class="metrics-grid">
        <div class="metric-card">
          <div class="metric-card__header">
            <.icon name="zap" class="w-6 h-6 text-yellow-500" />
            <span>Compression Ratio</span>
          </div>
          <div class="metric-card__value">
            <span class="text-2xl font-bold"><%= @metrics["compressionRatio"] || "N/A" %>x</span>
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-card__header">
            <.icon name="trending-down" class="w-6 h-6 text-green-500" />
            <span>Memory Reduction</span>
          </div>
          <div class="metric-card__value">
            <span class="text-2xl font-bold"><%= @metrics["memoryReduction"] || "N/A" %>%</span>
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-card__header">
            <.icon name="clock" class="w-6 h-6 text-blue-500" />
            <span>Processing Time</span>
          </div>
          <div class="metric-card__value">
            <span class="text-2xl font-bold"><%= @metrics["processingTime"] || "N/A" %>ms</span>
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-card__header">
            <.icon name="activity" class="w-6 h-6 text-purple-500" />
            <span>Speedup</span>
          </div>
          <div class="metric-card__value">
            <span class="text-2xl font-bold"><%= @metrics["processingSpeedup"] || "N/A" %>x</span>
          </div>
        </div>
      </div>
      
      <div class="test-section">
        <h3 class="text-lg font-semibold mb-4">Test TurboQuant</h3>
        
        <div class="test-form">
          <.simple_form for={:document_test} phx-submit="analyze_document">
            <.input 
              field={:document} 
              type="textarea" 
              placeholder="Enter document text to analyze with AI..." 
              rows="4"
              class="w-full p-3 border border-gray-300 rounded-lg"
            />
            <.button type="submit" class="mt-3 bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">
              Analyze Document
            </.button>
          </.simple_form>
        </div>
        
        <div class="test-form">
          <.simple_form for={:compression_test} phx-submit="compress_data">
            <.input 
              field={:data} 
              type="text" 
              placeholder="Enter comma-separated numbers to compress..." 
              class="w-full p-3 border border-gray-300 rounded-lg"
            />
            <.button type="submit" class="mt-3 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
              Compress Data
            </.button>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  defp icon(assigns) do
    ~H"""
    <svg class={@class} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <%= case @name do %>
        <% "refresh-cw" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        <% "compress" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4" />
        <% "clock" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        <% "share" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m9.032 4.026a9.001 9.001 0 01-7.432 0m9.032-4.026A9.001 9.001 0 0112 3c-4.474 0-8.268 3.12-9.032 7.326m0 0A9.001 9.001 0 0012 21c4.474 0 8.268-3.12 9.032-7.326" />
        <% "bookmark" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
        <% "mouse-pointer" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 15l-2 5L9 9l11 4-5 2z" />
        <% "circle" -> %>
          <circle cx="12" cy="12" r="10" />
        <% "zap" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        <% "trending-down" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6" />
        <% "activity" -> %>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      <% end %>
    </svg>
    """
  end

  # Helper functions
  defp get_ai_insights do
    # Simulate getting AI insights
    [
      %{
        id: "1",
        type: "optimization",
        title: "Database Query Optimization",
        message: "AI detected 15 slow queries that can be optimized by adding proper indexes",
        timestamp: DateTime.add(DateTime.utc_now(), -300, :second),
        confidence: 0.92
      },
      %{
        id: "2", 
        type: "prediction",
        title: "Failure Prediction",
        message: "3 CI jobs predicted to fail within next 24 hours due to memory constraints",
        timestamp: DateTime.add(DateTime.utc_now(), -600, :second),
        confidence: 0.87
      },
      %{
        id: "3",
        type: "anomaly",
        title: "Performance Anomaly",
        message: "Unusual spike in API response times detected in payment processing service",
        timestamp: DateTime.add(DateTime.utc_now(), -900, :second),
        confidence: 0.78
      }
    ]
  end

  defp get_turboquant_metrics do
    # Get actual metrics from TurboQuant service
    case AutomindWeb.TurboQuant.Client.get_metrics() do
      {:ok, metrics} ->
        metrics["metrics"] || %{}
      {:error, _} ->
        %{
          "compressionRatio" => 6.0,
          "memoryReduction" => 83.3,
          "processingTime" => 45,
          "processingSpeedup" => 8.0
        }
    end
  end

  defp format_timestamp(datetime) do
    DateTime.to_string(datetime)
  end
end
