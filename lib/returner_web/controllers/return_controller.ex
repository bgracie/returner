defmodule ReturnerWeb.ReturnController do
  use ReturnerWeb, :controller

  @type chart_data :: list(%{name: String.t(), data: list({Date.t(), Decimal.t()})})

  def index(conn, _params) do
    prices = %{
      portfolio_equities: [
        %{
          ticker: "FOO",
          prices: [
            {~D[2000-12-31], Money.new("1.0", :USD)},
            {~D[2001-01-01], Money.new("1.1", :USD)},
            {~D[2001-01-02], Money.new("1.2", :USD)},
            {~D[2001-01-03], Money.new("1.3", :USD)}
          ]
        },
        %{
          ticker: "BAR",
          prices: [
            {~D[2000-12-31], Money.new("3.0", :USD)},
            {~D[2001-01-01], Money.new("3.1", :USD)},
            {~D[2001-01-02], Money.new("3.2", :USD)},
            {~D[2001-01-03], Money.new("3.3", :USD)}
          ]
        }
      ],
      index: %{
        ticker: "BAZ",
        prices: [
          {~D[2000-12-31], Money.new("2.0", :USD)},
          {~D[2001-01-01], Money.new("2.1", :USD)},
          {~D[2001-01-02], Money.new("2.2", :USD)},
          {~D[2001-01-03], Money.new("2.3", :USD)}
        ]
      }
    }

    today = Date.utc_today()
    {:ok, one_year_ago} = Date.new(today.year - 1, today.month, today.day)
    query_range = Date.range(one_year_ago, today)
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
end
