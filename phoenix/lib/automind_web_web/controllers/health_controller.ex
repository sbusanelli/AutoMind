defmodule AutomindWebWeb.HealthController do
  use AutomindWebWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      status: "healthy",
      timestamp: DateTime.utc_now(),
      service: "automind_web"
    })
  end
end
