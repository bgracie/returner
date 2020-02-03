defmodule Returner.Cache do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def fetch_returns do
    Agent.get(__MODULE__, & &1)
  end

  def update_returns do
    returns = Returner.FetchReturns.perform(build_query_range())

    Agent.update(__MODULE__, fn _state -> returns end)

    returns
  end

  defp build_query_range do
    today = Date.utc_today()
    one_year_ago = Date.add(today, -365)

    Date.range(one_year_ago, today)
  end
end
