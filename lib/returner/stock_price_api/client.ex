defmodule Returner.StockPriceApi.Client do
  @moduledoc """
  Wraps the Alpha Vantage API
  """

  defmodule Behavior do
    @callback fetch_equity_prices(Returner.ticker(), DateRange.t()) :: Returner.equity_prices()
  end

  @behaviour __MODULE__.Behavior

  @api_key Application.fetch_env!(:returner, :alpha_vantage_api_key)

  @impl true
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
      |> Enum.sort(fn {date1, _price1}, {date2, _price2} -> Date.compare(date1, date2) != :gt end)

    %{
      ticker: ticker,
      prices: prices
    }
  end

  defp in_range?(date, date_range) do
    Date.compare(date, date_range.first) in [:gt, :eq] &&
      Date.compare(date, date_range.last) in [:lt, :eq]
  end

  defmodule Mock do
    @behaviour Returner.StockPriceApi.Client.Behavior

    @sample_money [Money.new(1, :USD), Money.new(2, :USD), Money.new(3, :USD)]

    @impl true
    def fetch_equity_prices(ticker, query_range) do
      %{
        ticker: ticker,
        prices: build_prices(query_range)
      }
    end

    defp build_prices(query_range) do
      Enum.map(query_range, fn date -> {date, Enum.random(@sample_money)} end)
    end
  end
end
