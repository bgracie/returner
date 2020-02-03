defmodule Returner.FetchReturns do
  @portfolio_tickers Returner.portfolio_tickers()
  @index_ticker Returner.index_ticker()

  @spec perform(Returner.query_range()) :: Returner.returns()
  def perform(query_range) do
    query_range
    |> get_prices()
    |> build_returns(query_range)
  end

  @spec get_prices(DateRange.t()) :: Returner.prices()
  def get_prices(query_range) do
    %{
      portfolio_equities: Enum.map(@portfolio_tickers, &fetch_equity_prices(&1, query_range)),
      index: fetch_equity_prices(@index_ticker, query_range)
    }
  end

  defp fetch_equity_prices(ticker, query_range) do
    Returner.StockPriceApi.Client.fetch_equity_prices(ticker, query_range)
  end

  @spec build_returns(Returner.prices(), Returner.query_range()) :: Returner.returns()
  def build_returns(prices, query_range) do
    daily_returns = build_daily_returns(prices, query_range)
    average_returns = build_average_returns(daily_returns)

    %{
      daily_returns: daily_returns,
      average_returns: average_returns,
      query_range: query_range
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
      current_date_closing_price
      |> Money.sub!(previous_date_closing_price)
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
      |> Decimal.round(2, :down)

    index_average_return =
      daily_returns.index
      |> calculate_equity_average_return()
      |> Decimal.round(2, :down)

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
  end
end
