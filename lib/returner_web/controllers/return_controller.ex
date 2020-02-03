defmodule ReturnerWeb.ReturnController do
  use ReturnerWeb, :controller

  @type chart_data :: list(%{name: String.t(), data: list({Date.t(), Decimal.t()})})

  def index(conn, _params) do
    query_range = build_query_range()
    prices = Returner.get_prices(query_range)
    returns = Returner.build_returns(prices, query_range)

    render(conn, "index.html",
      chart_data: build_chart_data(returns.daily_returns),
      portfolio_average_return: returns.average_returns.portfolio,
      index_average_return: returns.average_returns.index
    )
  end

  @spec build_chart_data(Returner.daily_returns()) :: chart_data()
  def build_chart_data(daily_returns) do
    index_series = build_chart_series(daily_returns.index)
    portfolio_series = Enum.map(daily_returns.portfolio_equities, &build_chart_series/1)

    [index_series | portfolio_series]
  end

  defp build_chart_series(equity_daily_returns) do
    %{
      name: equity_daily_returns.ticker,
      data: equity_daily_returns.returns
    }
  end

  defp build_query_range do
    today = Date.utc_today()
    one_year_ago = Date.add(today, -365)

    Date.range(one_year_ago, today)
  end
end
