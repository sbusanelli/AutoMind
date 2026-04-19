defmodule AutomindWebWeb.Router do
  use AutomindWebWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AutomindWebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AutomindWebWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/ai-insights", AIInsightsLive, :index
    live "/operations", OperationsLive, :index
    live "/metrics", MetricsLive, :index
    live "/ai-chat", AIChatLive, :index
    live "/performance", PerformanceLive, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", AutomindWebWeb do
    pipe_through :api

    get "/health", HealthController, :index
    post "/turboquant/compress", TurboQuantController, :compress
    post "/turboquant/decompress", TurboQuantController, :decompress
    get "/turboquant/metrics", TurboQuantController, :metrics
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:automind_web, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AutomindWebWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
