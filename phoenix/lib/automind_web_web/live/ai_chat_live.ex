defmodule AutomindWebWeb.AIChatLive do
  use AutomindWebWeb, :live_view

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "AI Chat")
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AutomindWeb.PubSub, "ai_chat")
    end

    socket =
      socket
      |> assign(:messages, [
        %{id: 1, role: "assistant", content: "Hello! I'm your AI assistant. How can I help you today?", timestamp: DateTime.utc_now()},
        %{id: 2, role: "user", content: "Can you show me the system status?", timestamp: DateTime.utc_now()},
        %{id: 3, role: "assistant", content: "The system is running optimally with 99.8% uptime and all services operational.", timestamp: DateTime.utc_now()}
      ])
      |> assign(:input, "")

    {:ok, socket}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    new_message = %{
      id: Enum.count(socket.assigns.messages) + 1,
      role: "user",
      content: message,
      timestamp: DateTime.utc_now()
    }

    # Simulate AI response
    ai_response = %{
      id: Enum.count(socket.assigns.messages) + 2,
      role: "assistant",
      content: generate_ai_response(message),
      timestamp: DateTime.utc_now()
    }

    socket =
      socket
      |> assign(:messages, socket.assigns.messages ++ [new_message, ai_response])
      |> assign(:input, "")

    {:noreply, socket}
  end

  defp generate_ai_response(user_message) do
    cond do
      String.contains?(user_message, "status") ->
        "All systems are operational. CPU usage is at 45%, memory at 68%, and we have 99.8% uptime."
      String.contains?(user_message, "performance") ->
        "System performance is excellent. Response times are averaging 120ms with a 0.02% error rate."
      String.contains?(user_message, "help") ->
        "I can help you monitor system status, analyze performance metrics, and provide operational insights. What would you like to know?"
      true ->
        "I understand you're asking about: " <> user_message <> ". Let me help you with that."
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">AI Chat</h1>
      
      <div class="bg-white rounded-lg shadow max-w-4xl mx-auto">
        <div class="border-b border-gray-200">
          <div class="p-4 space-y-4 h-96 overflow-y-auto" id="chat-messages">
            <%= for message <- @messages do %>
              <div class={"flex " <> if(message.role == "user", do: "justify-end", else: "justify-start")}>
                <div class={"max-w-xs lg:max-w-md px-4 py-2 rounded-lg " <> 
                  if(message.role == "user", do: "bg-blue-600 text-white", else: "bg-gray-100 text-gray-900")}>
                  <p class="text-sm"><%= message.content %></p>
                  <p class={"text-xs mt-1 " <> if(message.role == "user", do: "text-blue-200", else: "text-gray-500")}>
                    <%= Calendar.strftime(message.timestamp, "%H:%M") %>
                  </p>
                </div>
              </div>
            <% end %>
          </div>
        </div>
        
        <div class="p-4 border-t border-gray-200">
          <form phx-submit="send_message" class="flex space-x-2">
            <input 
              type="text" 
              name="message" 
              value={@input}
              placeholder="Type your message..." 
              class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              phx-target="#chat-form"
            />
            <button 
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              Send
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
