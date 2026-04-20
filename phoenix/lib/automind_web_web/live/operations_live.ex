defmodule AutomindWebWeb.OperationsLive do
  use AutomindWebWeb, :live_view

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Operations")
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "operations")
    end

    socket =
      socket
      |> assign(:operations, [
        %{id: 1, name: "Data Processing", status: "running", progress: 75},
        %{id: 2, name: "AI Model Training", status: "queued", progress: 0},
        %{id: 3, name: "System Backup", status: "completed", progress: 100}
      ])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Operations</h1>
      
      <div class="bg-white rounded-lg shadow">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Active Operations</h2>
        </div>
        <div class="p-6">
          <%= for operation <- @operations do %>
            <div class="mb-4 p-4 bg-gray-50 rounded-lg">
              <div class="flex justify-between items-center">
                <div>
                  <h3 class="text-sm font-medium text-gray-900"><%= operation.name %></h3>
                  <p class="text-sm text-gray-500">Status: <%= operation.status %></p>
                </div>
                <div class="w-32">
                  <div class="bg-gray-200 rounded-full h-2">
                    <div class="bg-blue-600 h-2 rounded-full" style={"width: #{operation.progress}%"}></div>
                  </div>
                  <p class="text-xs text-gray-500 mt-1"><%= operation.progress %>%</p>
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
