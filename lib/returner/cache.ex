defmodule Returner.Cache do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def fetch_returns(query_range) do
    case Agent.get(__MODULE__, & &1) do
      nil -> update_returns(query_range)
      returns -> returns
    end
  end

  def update_returns(query_range) do
    returns = Returner.FetchReturns.perform(query_range)

    Agent.update(__MODULE__, fn _state -> returns end)

    returns
  end
end
