defmodule AutomindWebWeb.DashboardComponents do
  @moduledoc """
  Dashboard components for the AutoMind dashboard.
  """
  use Phoenix.Component

  @doc """
  Renders a metric card with title, value, icon, trend, and color.
  """
  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :icon, :string, required: false, default: "chart-bar"
  attr :trend, :string, required: false, default: ""
  attr :color, :string, required: false, default: "blue"

  def metric_card(assigns) do
    ~H"""
    <div class="metric-card bg-#{@color}-50 border-l-4 border-#{@color}-200 rounded-lg p-6">
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <svg class="h-8 w-8 text-#{@color}-600" fill="currentColor" viewBox="0 0 24 24">
            <path d="M9 19v-6a2 2 0 01-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h12a2 2 0 002-2v-6a2 2 0 01-2-2z"/>
          </svg>
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-900"><%= @title %></p>
          <p class="text-2xl font-semibold text-gray-900"><%= @value %></p>
          <%= if @trend != "" do %>
            <p class="text-sm text-#{@color}-600"><%= @trend %></p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the dashboard header.
  """
  def header(assigns) do
    ~H"""
    <header class="dashboard-header bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-6">
          <div class="flex items-center">
            <h1 class="text-3xl font-bold text-gray-900">AutoMind Dashboard</h1>
            <p class="ml-4 text-gray-600">Real-time AI Operations Monitoring</p>
          </div>
          <div class="flex items-center space-x-4">
            <button class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium">
              Refresh
            </button>
            <button class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md text-sm font-medium">
              Optimize
            </button>
          </div>
        </div>
      </div>
    </header>
    """
  end
end
