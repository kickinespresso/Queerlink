defmodule Queerlink.Shortener do
@moduledoc false
use GenServer
require Logger

@tab :shortened_urls
@server __MODULE__

  def start_link, do: GenServer.start_link(__MODULE__, __MODULE__, name: @server)

  def get_url(id),  do: GenServer.call(@server, {:get_url, id})
  def put_utl(url), do: GenServer.call(@server, {:put_url, url})

  # GenServer API

  def init(_args) do
    Logger.debug("Shortener Initialiased")
    :ets.new(@tab, [:named_table])
    {:ok, %St{next: 0}}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle_call({:get_url, id}, _from, state) do
    reply = case :ets.lookup(@tab, id) do
      [] -> {:error, :not_found}
      [{_id, url}] -> {:ok, url}
    end
    {:reply, reply, state}
  end

  def handle_call({:put_url, url}, _from, state) do
    %St{next: n} = state
    id = b36_encode(n)
    :ets.insert(@tab, {id, url})
    {:reply, {:ok, id}, %St{next: n+1}}
  end

  def handle_call(_req, _from, state) do
    {:stop, :unkown_call, state}
  end

  def handle_cast(_req, state) do
    {:stop, :unknown_cast, state}
  end

  def handle_info(_info, state) do
    {:stop, :unknown_info, state}
  end
  def b36_encode(n) do
    Integer.to_string(n, 36)
  end
end