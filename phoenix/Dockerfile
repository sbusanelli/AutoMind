# Phoenix LiveView Dockerfile for AutoMind
FROM elixir:1.15-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base npm git python3

# Prepare build directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install dependencies
COPY mix.exs mix.lock ./
COPY config/config.exs config/
RUN mix deps.get --only prod
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix assets ci --only=production

# Copy source code
COPY . .

# Compile assets
RUN npm run --prefix assets deploy
RUN mix phx.digest

# Compile the release
RUN mix release

# Prepare a new release image
FROM alpine:3.18 AS app

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

# Copy the release build
COPY --from=builder /app/_build/prod/rel/automind_web ./

# Create non-root user
RUN addgroup -g 1000 -S automind && \
    adduser -S automind -u 1000

# Change ownership of the app directory
RUN chown -R automind:automind /app

USER automind

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:4000/api/health || exit 1

# Expose port
EXPOSE 4000

# Set environment variables
ENV PORT=4000
ENV ERL_AFLAGS="-kernel shell_history.enabled -kernel error_logger silent"
ENV MIX_ENV=prod

# Start the Phoenix server
CMD ["bin/automind_web", "start"]
