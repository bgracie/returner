defmodule ReturnerWeb.ReturnController do
  use ReturnerWeb, :controller

  @type chart_data :: list(%{name: String.t(), data: list({Date.t(), Decimal.t()})})

  def index(conn, _params) do
    case Returner.fetch_returns() do
      {:ok, returns} ->
        render(conn, "index.html",
          chart_data: build_chart_data(returns.daily_returns),
          portfolio_average_return: returns.average_returns.portfolio,
          index_average_return: returns.average_returns.index
        )

      {:error, :not_loaded} ->
        render(conn, "not_loaded.html")
    end
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
