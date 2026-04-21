defmodule AutomindWeb.Repo do
  use Ecto.Repo,
    otp_app: :automind_web,
    adapter: Ecto.Adapters.Postgres
end
