# AutoMind Phoenix LiveView Integration

## Overview

This Phoenix LiveView application provides real-time AI-powered operational intelligence for AutoMind, leveraging Google's TurboQuant compression technology for maximum performance and efficiency.

## Features

### Real-Time Dashboard
- **Live Metrics**: Real-time operational metrics with automatic updates
- **AI Insights**: AI-generated insights and predictions
- **Performance Monitoring**: System health and performance tracking
- **Cost Optimization**: Real-time cost savings calculations

### TurboQuant Integration
- **6x Memory Reduction**: KV cache compression with zero accuracy loss
- **Real-Time Compression**: Dynamic data compression during processing
- **Performance Metrics**: Live compression statistics and benchmarks
- **Multi-Provider Support**: Integration with OpenAI, Anthropic, and local models

### AI Operations
- **Natural Language Interface**: Ask questions in plain English
- **Predictive Analytics**: ML models predict failures before they occur
- **Automated Remediation**: AI fixes common issues automatically
- **Document Analysis**: AI-powered document processing and insights

## Architecture

```
Phoenix LiveView (Frontend)
        ||
        || WebSocket + PubSub
        ||
        ||
Node.js Backend (TurboQuant)
        ||
        ||
PostgreSQL + Redis
```

## Quick Start

### Prerequisites
- Elixir 1.15+
- PostgreSQL 14+
- Redis 6+
- Node.js 18+ (for TurboQuant backend)

### Installation

1. **Clone and setup Phoenix app**:
```bash
cd phoenix
mix deps.get
mix ecto.create
mix ecto.migrate
```

2. **Start dependencies**:
```bash
# Start Redis
redis-server

# Start PostgreSQL (if not running)
brew services start postgresql  # macOS
sudo systemctl start postgresql   # Linux

# Start Node.js TurboQuant backend
cd ../backend
npm start
```

3. **Start Phoenix LiveView**:
```bash
cd phoenix
mix phx.server
```

4. **Visit the application**:
Open http://localhost:4000 in your browser

## LiveView Pages

### Dashboard (`/`)
Main dashboard with real-time operational intelligence:
- Active jobs monitoring
- AI insights feed
- Performance metrics
- System health indicators
- Cost savings tracking

### AI Insights (`/ai-insights`)
Detailed AI analysis and TurboQuant integration:
- Latest AI insights with detailed information
- TurboQuant performance metrics
- Document analysis tools
- Data compression testing
- Real-time compression statistics

### Operations (`/operations`)
Operational monitoring and management:
- System resource monitoring
- Job queue status
- Performance graphs
- Alert management

### Metrics (`/metrics`)
Detailed performance and system metrics:
- Response time charts
- Success rate tracking
- Error rate monitoring
- Throughput statistics

### AI Chat (`/ai-chat`)
Interactive AI assistant:
- Natural language queries
- Real-time AI responses
- Operational guidance
- Optimization suggestions

### Performance (`/performance`)
Performance analysis and optimization:
- Benchmark results
- Resource utilization
- Optimization recommendations
- Historical performance data

## TurboQuant Integration

### Configuration
Configure TurboQuant integration in `config/config.exs`:

```elixir
config :automind_web, :turboquant,
  node_backend_url: "http://localhost:3000",
  api_key: System.get_env("TURBOQUANT_API_KEY"),
  timeout: 30_000,
  retry_attempts: 3
```

### Usage Examples

#### Data Compression
```elixir
# Compress data using TurboQuant
{:ok, result} = AutomindWeb.TurboQuant.Client.compress_data([1.0, 2.0, 3.0])

# Decompress data
{:ok, decompressed} = AutomindWeb.TurboQuant.Client.decompress_data(
  result["data"], 
  result["metadata"]
)
```

#### Document Analysis
```elixir
# Analyze document with AI
{:ok, analysis} = AutomindWeb.TurboQuant.Client.process_document(
  "Your document text here...", 
  "summary"
)
```

#### Performance Metrics
```elixir
# Get TurboQuant metrics
{:ok, metrics} = AutomindWeb.TurboQuant.Client.get_metrics()
```

## Real-Time Features

### Phoenix PubSub Channels
- `"ai_insights"` - Real-time AI insights
- `"job_updates"` - Job status updates
- `"performance_metrics"` - Performance monitoring
- `"turboquant_metrics"` - TurboQuant metrics

### LiveView Updates
All LiveViews automatically update when new data is available:
- Dashboard updates every 5 seconds
- AI insights update in real-time
- Performance metrics stream continuously
- System health monitoring is live

## Performance Benefits

### Phoenix LiveView Advantages
- **97% less memory per connection** (~1.5KB vs 50KB)
- **200x more concurrent users** (2M+ vs 10K)
- **10x faster updates** (10-50ms vs 100-500ms)
- **80% server cost reduction**

### TurboQuant Benefits
- **6x memory reduction** for LLM operations
- **50%+ cost savings** on AI inference
- **8x faster processing** on GPU accelerators
- **Zero accuracy loss** with 3-bit quantization

## Development

### Running Tests
```bash
mix test
```

### Code Quality
```bash
mix format
mix credo
mix dialyzer
```

### Live Development
```bash
# Start with live reload
mix phx.server

# View LiveDashboard
http://localhost:4000/dev/dashboard
```

## Deployment

### Docker Deployment
```bash
# Build Docker image
docker build -t automind-web .

# Run with Docker Compose
docker-compose up -d
```

### Production Configuration
```elixir
# config/prod.exs
config :automind_web, AutomindWebWeb.Endpoint,
  url: [host: "your-domain.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :automind_web, AutomindWeb.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
```

## Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost/automind_prod

# Redis
REDIS_URL=redis://localhost:6379

# TurboQuant
NODE_BACKEND_URL=http://backend:3000
TURBOQUANT_API_KEY=your-api-key

# Phoenix
SECRET_KEY_BASE=your-secret-key
PORT=4000
```

## Monitoring

### LiveDashboard
Access real-time metrics at `/dev/dashboard` (development only)

### Telemetry
Metrics are automatically collected for:
- LiveView performance
- Database queries
- Phoenix PubSub
- TurboQuant operations

### Health Checks
```bash
# API health check
curl http://localhost:4000/api/health

# TurboQuant health check
curl http://localhost:4000/api/turboquant/metrics
```

## Troubleshooting

### Common Issues

**Phoenix won't start**
```bash
# Check Elixir version
elixir --version

# Rebuild dependencies
mix deps.clean --all
mix deps.get
```

**TurboQuant connection failed**
```bash
# Check Node.js backend is running
curl http://localhost:3000/api/health

# Verify configuration
grep -r turboquant config/
```

**Redis connection failed**
```bash
# Check Redis is running
redis-cli ping

# Verify Redis URL
echo $REDIS_URL
```

### Performance Tuning

**Phoenix Performance**
```elixir
# config/dev.exs
config :phoenix, :logger,
  level: :info

# Increase concurrent connections
config :automind_web, AutomindWebWeb.Endpoint,
  websocket: [
    max_frame_size: 8_000_000,
    timeout: 60_000
  ]
```

**TurboQuant Optimization**
```elixir
# Enable GPU acceleration
config :automind_web, :turboquant,
  enable_gpu: true,
  batch_size: 64,
  max_memory: 2048
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- **Documentation**: [AutoMind Wiki](https://github.com/sbusanelli/AutoMind/wiki)
- **Issues**: [GitHub Issues](https://github.com/sbusanelli/AutoMind/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sbusanelli/AutoMind/discussions)

---

**Built with Phoenix LiveView + TurboQuant for maximum real-time performance**
