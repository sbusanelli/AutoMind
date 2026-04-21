defmodule AutomindWebWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component
  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.LiveView.JS

  @doc """
  Renders a modal.
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, :any, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full",
        hidden: !@show
      ]}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
    >
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3 text-center">
          <%= render_slot(@inner_block) %>
        </div>
        <div class="mt-4">
          <%= if @on_cancel do %>
            <button
              type="button"
              class="inline-flex justify-center w-full px-4 py-2 text-base font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              phx-click={@on_cancel}
              phx-target={@myself}
            >
              Cancel
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a table.
  """
  attr :id, :string, default: nil
  attr :rows, :list, required: true
  attr :class, :string, default: nil

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, required: false

  def table(assigns) do
    ~H"""
    <table id={@id} class={["min-w-full divide-y divide-gray-200", @class]}>
      <thead class="bg-gray-50">
        <tr>
          <%= for col <- @col do %>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              <%= col[:label] %>
            </th>
          <% end %>
          <%= if @action do %>
            <th class="relative px-6 py-3">
              <span class="sr-only">Actions</span>
            </th>
          <% end %>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        <%= for row <- @rows do %>
          <tr class="hover:bg-gray-50">
            <%= for col <- @col do %>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                <%= render_slot(col, row) %>
              </td>
            <% end %>
            <%= if @action do %>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <%= render_slot(@action, row) %>
              </td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  @doc """
  Renders a button.
  """
  attr :type, :string, default: "button"
  attr :class, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2",
        "bg-indigo-600 hover:bg-indigo-700 focus:ring-indigo-500 text-white": !@disabled,
        "bg-gray-300 cursor-not-allowed": @disabled
      ]}
      disabled={@disabled}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a card.
  """
  attr :class, :string, default: nil
  attr :rest, :global

  slot :header, required: false
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={["bg-white overflow-hidden shadow rounded-lg", @class]} {@rest}>
      <%= if @header do %>
        <div class="px-4 py-5 sm:p-6">
          <%= render_slot(@header) %>
        </div>
      <% end %>
      <div class="px-4 py-5 sm:p-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  # Form helpers
  def simple_form(assigns) do
    ~H"""
    <form {@rest}>
      <%= render_slot(@inner_block) %>
    </form>
    """
  end

  def input(assigns) do
    ~H"""
    <input type={@type} name={@name} id={@id} value={@value} class={@class} {@rest} />
    """
  end

  # Modal helpers
  defp show_modal(id) when is_binary(id) do
    JS.new()
    |> JS.show(to: "##{id}")
    |> JS.show(to: "##{id}-bg")
    |> JS.add_class("overflow-hidden", to: "body")
  end

  defp hide_modal(id) when is_binary(id) do
    JS.new()
    |> JS.hide(to: "##{id}")
    |> JS.hide(to: "##{id}-bg")
    |> JS.remove_class("overflow-hidden", to: "body")
  end
end
