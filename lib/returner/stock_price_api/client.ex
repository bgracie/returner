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
      |> Enum.sort(fn {date1, _price1}, {date2, _price2} -> Date.compare(date1, date2) != :gt end)
      |> filter_by_range(query_range)

    %{
      ticker: ticker,
      prices: prices
    }
  end

  defp filter_by_range(prices, query_range) do
    first_date_in_period =
      Enum.find_index(prices, fn {date, _price} ->
        Date.compare(date, query_range.first) != :lt
      end)

    last_date_before_period = first_date_in_period - 1

    first_date_after_period =
      Enum.find_index(prices, fn {date, _price} ->
        Date.compare(date, query_range.last) == :gt
      end) || length(prices)

    last_date_in_period = first_date_after_period - 1

    Enum.slice(prices, last_date_before_period..last_date_in_period)
  end

  defmodule Mock do
    @behaviour Returner.StockPriceApi.Client.Behavior

    @sample_money [Money.new(1, :USD), Money.new(2, :USD), Money.new(3, :USD)]

    @impl true
    def fetch_equity_prices(ticker, query_range) do
      adjusted_beginning = Date.add(query_range.first, -1)
      adjusted_range = Date.range(adjusted_beginning, query_range.last)

      %{
        ticker: ticker,
        prices: build_prices(adjusted_range)
      }
    end

    defp build_prices(query_range) do
      Enum.map(query_range, fn date -> {date, Enum.random(@sample_money)} end)
    end
  end
end
