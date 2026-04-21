defmodule AutomindWebWeb.Layouts do
  @moduledoc """
  Layouts for AutoMind web application.
  """
  use AutomindWebWeb, :html

  embed_templates "layouts/*"

  def root(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>AutoMind</title>
        <link rel="stylesheet" href="/assets/app.css"/>
        <script defer phx-track-static type="text/javascript" src="/assets/app.js"></script>
      </head>
      <body class="bg-white">
        <%= @inner_content %>
      </body>
    </html>
    """
  end

  def app(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <header class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">AutoMind Dashboard</h1>
        <p class="text-gray-600">AI-Powered Operational Intelligence</p>
      </header>
      
      <main>
        <%= @inner_content %>
      </main>
      
      <footer class="mt-8 text-center text-gray-500 text-sm">
        <p>© 2024 AutoMind - Autonomous AI Operations</p>
      </footer>
    </div>
    """
  end
end
