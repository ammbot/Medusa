defmodule Medusa.Broker do
  @moduledoc false
  use GenServer

  # API
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Adds a new route to the broker. If there is an existing route, 
  it just ignores it. 
  """  
  def new_route(event) do
    GenServer.call(__MODULE__, {:new_route, event})
  end

  @doc """
  Sends to the matching routes the event, using the configured adapter.

  TODO: Make this async.
  """
  def publish(event, payload) do
    GenServer.cast(__MODULE__, {:publish, event, payload})
  end

  # Callbacks
  def init(_opts) do
    {:ok, []}
  end

  def handle_call({:new_route, event}, _from, state) do
    if Enum.find(state, fn(e) -> e == event end) do
      {:reply, :ok, state}
    else
      state = [event | state]
      {:reply, :ok, state}
    end

  end

  @adapter Keyword.get(Application.get_env(:medusa, Medusa), :adapter)

  def handle_cast({:publish, event, payload}, state) do
    Enum.each(state, fn(e) ->
      if Regex.match?(e, event) do
        @adapter.insert(base64_encode_regex(e), payload)
        GenServer.cast (base64_encode_regex(e) |> String.to_atom), {:trigger}
      end
    end)
    {:noreply, state}
  end


  def base64_encode_regex(regex) do
    Regex.source(regex) |> :base64.encode
  end
end