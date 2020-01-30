defmodule Returner do
  @type ticker :: String.t()
  @type price :: Money.t()
  @type equity_prices :: %{ticker: ticker(), prices: list({Date.t(), price()})}
  @type prices :: %{portfolio_equities: list(equity_prices()), index: equity_prices()}

  # As a percentage
  @type return :: Decimal.t()
  @type equity_daily_returns :: %{ticker: ticker(), returns: list({Date.t(), return()})}
  @type daily_returns :: %{
          portfolio_equities: list(equity_daily_returns()),
          index: equity_daily_returns()
        }

  @type average_returns :: %{portfolio: return(), index: return()}

  @type returns :: %{daily_returns: daily_returns(), average_returns: average_returns()}

  @spec build_returns(prices(), Date.Range.t()) :: returns()
  def build_returns(prices, date_range) do
    daily_returns = build_daily_returns(prices, date_range)
    average_returns = build_average_returns(daily_returns)

    %{
      daily_returns: daily_returns,
      average_returns: average_returns
    }
  end

  defp build_daily_returns(prices, date_range) do
    portfolio_equity_daily_returns =
      Enum.map(prices.portfolio_equities, &build_equity_daily_returns(&1, date_range))

    %{
      portfolio_equities: portfolio_equity_daily_returns,
      index: build_equity_daily_returns(prices.index, date_range)
    }
  end

  defp build_equity_daily_returns(prices, _date_range) do
    returns =
      prices.prices
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&build_daily_return/1)

    %{ticker: prices.ticker, returns: returns}
  end

  defp build_daily_return([
         {_previous_date, previous_date_closing_price},
         {current_date, current_date_closing_price}
       ]) do
    return =
      Money.sub!(current_date_closing_price, previous_date_closing_price)
      |> div_money(previous_date_closing_price)
      |> Decimal.mult(100)
      |> Decimal.round(1, :down)

    {current_date, return}
  end

  defp div_money(%{amount: left, currency: currency}, %{amount: right, currency: currency}) do
    Decimal.div(left, right)
  end

  defp build_average_returns(daily_returns) do
    portfolio_average_return =
      daily_returns.portfolio_equities
      |> Enum.map(&calculate_equity_average_return/1)
      |> average()

    index_average_return = calculate_equity_average_return(daily_returns.index)

    %{
      portfolio: portfolio_average_return,
      index: index_average_return
    }
  end

  defp calculate_equity_average_return(equity_daily_returns) do
    equity_daily_returns.returns
    |> Enum.map(fn {_date, return} -> return end)
    |> average()
  end

  defp average(decimals) do
    decimals
    |> Enum.reduce(&Decimal.add/2)
    |> Decimal.div(length(decimals))
    |> Decimal.round(1, :down)
  end
end
