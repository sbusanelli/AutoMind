import Config

# Configure the database
config :automind_web, AutomindWeb.Repo,
  username: System.get_env("DB_USERNAME", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME", "automind_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# Configure the endpoint
config :automind_web, AutomindWebWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: AutomindWebWeb.ErrorHTML, json: AutomindWebWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AutomindWeb.PubSub,
  live_view: [signing_salt: "automind_live_view_salt"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.0",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Redis for Phoenix PubSub and caching
config :automind_web, AutomindWeb.PubSub,
  adapter: Phoenix.PubSub.Redis,
  redis_url: System.get_env("REDIS_URL", "redis://localhost:6379"),
  node_name: System.get_env("NODE_NAME", "automind_1")

# Configure Redis connection
config :redis,
  url: System.get_env("REDIS_URL", "redis://localhost:6379"),
  name: :automind_redis

# Configure TurboQuant integration
config :automind_web, :turboquant,
  node_backend_url: System.get_env("NODE_BACKEND_URL", "http://localhost:3000"),
  api_key: System.get_env("TURBOQUANT_API_KEY"),
  timeout: 30_000,
  retry_attempts: 3

# Configure AI operations
config :automind_web, :ai_operations,
  update_interval: String.to_integer(System.get_env("AI_UPDATE_INTERVAL", "1000")),
  max_insights: String.to_integer(System.get_env("MAX_INSIGHTS", "100")),
  prediction_window: String.to_integer(System.get_env("PREDICTION_WINDOW", "86400")) # 24 hours

# Configure performance monitoring
config :automind_web, :telemetry,
  metrics: [
    {Phoenix.LiveView, :telemetry_metrics},
    {Phoenix.Ecto, :telemetry_metrics},
    {Phoenix.PubSub, :telemetry_metrics}
  ],
  pollers: [
    {Telemetry.Poller, :telemetry_metrics, period: 10_000}
  ]

# Configure Phoenix LiveDashboard
config :phoenix_live_dashboard,
  metrics: AutomindWebWeb.Telemetry,
  ecto_repos: [AutomindWeb.Repo],
  router: AutomindWebWeb.Router,
  env_key: "DASHBOARD_SECRET"

# Configure Swoosh for email
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: AutomindWeb.Finch

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
