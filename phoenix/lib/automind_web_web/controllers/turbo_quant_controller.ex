defmodule AutomindWebWeb.TurboQuantController do
  use AutomindWebWeb, :controller

  def compress(conn, %{"data" => data}) do
    # Forward to Node.js backend
    case Req.post("http://localhost:5000/api/turboquant/compress", json: %{"data" => data}) do
      {:ok, response} ->
        json(conn, response.body)
      
      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: "Failed to compress data", reason: inspect(reason)})
    end
  end

  def decompress(conn, %{"data" => data, "metadata" => metadata}) do
    # Forward to Node.js backend
    case Req.post("http://localhost:5000/api/turboquant/decompress", json: %{"data" => data, "metadata" => metadata}) do
      {:ok, response} ->
        json(conn, response.body)
      
      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: "Failed to decompress data", reason: inspect(reason)})
    end
  end

  def metrics(conn, _params) do
    # Forward to Node.js backend
    case Req.get("http://localhost:5000/api/turboquant/metrics") do
      {:ok, response} ->
        json(conn, response.body)
      
      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: "Failed to get metrics", reason: inspect(reason)})
    end
  end
end
