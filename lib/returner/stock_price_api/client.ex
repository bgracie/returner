defmodule Returner.StockPriceApi.Client do
  @moduledoc """
  Wraps the Alpha Vantage API
  """

  @api_key Application.fetch_env!(:returner, :alpha_vantage_api_key)

  @spec fetch_equity_prices(Returner.ticker(), DateRange.t()) :: Returner.equity_prices()
  def fetch_equity_prices(ticker, query_range) do
    ticker
    |> request_equity_prices()
    |> build_equity_prices(ticker, query_range)
  end

  def request_equity_prices(ticker) do
    {:ok, {{_httpv, 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {build_equity_prices_query_url(ticker), []}, [], [])

    Jason.decode!(body)
  end

  def build_equity_prices_query_url(ticker) do
    ("https://www.alphavantage.co/query?" <>
       "function=TIME_SERIES_DAILY&symbol=#{ticker}&outputsize=full&apikey=#{@api_key}")
    |> String.to_charlist()
  end

  def build_equity_prices(response_body, ticker, query_range) do
    prices =
      response_body
      |> Map.fetch!("Time Series (Daily)")
      |> Enum.map(fn {date_string, prices} ->
        {Date.from_iso8601!(date_string), Money.new(prices["4. close"], :USD)}
      end)
      |> Enum.filter(fn {date, _price} -> in_range?(date, query_range) end)
      |> Enum.sort(fn {date1, _price1}, {date2, _price2} -> Date.compare(date1, date2) != :lt end)

    %{
      ticker: ticker,
      prices: prices
    }
  end

  defp in_range?(date, date_range) do
    Date.compare(date, date_range.first) in [:gt, :eq] &&
      Date.compare(date, date_range.last) in [:lt, :eq]
  end
end
