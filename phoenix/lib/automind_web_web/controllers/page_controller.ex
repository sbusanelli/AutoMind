defmodule AutomindWebWeb.PageController do
  use AutomindWebWeb, :controller

  def dashboard(conn, _params) do
    render(conn, :dashboard)
  end
end
