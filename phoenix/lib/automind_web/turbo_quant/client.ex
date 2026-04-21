defmodule AutomindWeb.TurboQuant.Client do
  @moduledoc false

  use GenServer
  require Logger

  @backend_url Application.compile_env(:automind_web, :turboquant)[:node_backend_url] || "http://localhost:3000"

  # Client API
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  def compress_data(data, opts \\ []) do
    GenServer.call(__MODULE__, {:compress, data, opts})
  end

  def decompress_data(data, metadata, opts \\ []) do
    GenServer.call(__MODULE__, {:decompress, data, metadata, opts})
  end

  def get_metrics do
    GenServer.call(__MODULE__, :get_metrics)
  end

  def process_document(document, analysis_type, opts \\ []) do
    GenServer.call(__MODULE__, {:process_document, document, analysis_type, opts})
  end

  # GenServer Callbacks
  @impl true
  def init(_init_arg) do
    Logger.info("TurboQuant client starting...")
    {:ok, %{}}
  end

  @impl true
  def handle_call({:compress, data, opts}, _from, state) do
    bit_width = Keyword.get(opts, :bit_width, 3)
    
    case make_request("/api/turboquant/compress", %{
      "data" => data,
      "bitWidth" => bit_width
    }) do
      {:ok, response} ->
        {:reply, {:ok, response}, state}
      {:error, reason} ->
        Logger.error("TurboQuant compression failed: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:decompress, data, metadata, opts}, _from, state) do
    case make_request("/api/turboquant/decompress", %{
      "data" => data,
      "metadata" => metadata
    }) do
      {:ok, response} ->
        {:reply, {:ok, response}, state}
      {:error, reason} ->
        Logger.error("TurboQuant decompression failed: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    case make_request("/api/turboquant/metrics", %{}) do
      {:ok, response} ->
        {:reply, {:ok, response}, state}
      {:error, reason} ->
        Logger.error("TurboQuant metrics failed: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:process_document, document, analysis_type, opts}, _from, state) do
    provider = Keyword.get(opts, :provider, "openai")
    
    case make_request("/api/turboquant/process-document", %{
      "document" => document,
      "analysisType" => analysis_type,
      "provider" => provider
    }) do
      {:ok, response} ->
        {:reply, {:ok, response}, state}
      {:error, reason} ->
        Logger.error("TurboQuant document processing failed: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end

  # Private helper functions
  defp make_request(endpoint, payload) do
    url = "#{@backend_url}#{endpoint}"
    
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    case Req.post(url, json: payload, headers: headers, receive_timeout: 30_000) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}
      {:ok, %{status: status, body: body}} when status in 400..499 ->
        {:error, {:client_error, status, body}}
      {:ok, %{status: status, body: body}} when status >= 500 ->
        {:error, {:server_error, status, body}}
      {:ok, %{status: status}} ->
        {:error, {:unexpected_status, status}}
      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end
end
