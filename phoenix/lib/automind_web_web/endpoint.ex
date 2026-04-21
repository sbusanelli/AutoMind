defmodule AutomindWebWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :automind_web

  # The session will be stored in cookie and signed,
  # this means you can include only data you need in the session
  # and it won't be accessible from client side.
  @session_key :automind_web_key
  @session_options [
    store: :cookie,
    key: "_automind_web_web_session_key",
    signing_salt: "automind_web",
    same_site: "Lax",
    max_age: 86400 * 14,
    path: "/"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [
      connect_info: [:user_agent, :peer_data, :uri, :x_headers],
      timeout: 60_000
    ]

  # Serve at "/" the static files from "priv/static" directory.
  plug Plug.Static,
    at: "/",
    from: :automind_web,
    gzip: false,
    only: ["priv/static"]

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug AutomindWebWeb.Router

  plug :put_secure_browser_headers

  defp put_secure_browser_headers(conn, _opts) do
    conn
    |> put_resp_header("x-content-type-options", "nosniff")
    |> put_resp_header("x-frame-options", "SAMEORIGIN")
    |> put_resp_header("x-xss-protection", "1; mode=block")
    |> put_resp_header("x-download-options", "noopen")
    |> put_resp_header("x-permitted-cross-domain-policies", "none")
    |> put_resp_header("cross-origin-opener-policy", "same-origin")
    |> put_resp_header("cross-origin-resource-policy", "cross-origin")
  end
end
