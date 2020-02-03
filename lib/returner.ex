defmodule Returner do
  @portfolio_tickers [
    "AAPL",
    "GOOGL",
    "MSFT",
    "DELL"
  ]

  @index_ticker "DJIA"

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

  @spec fetch_returns :: {:ok, returns()} | {:error, any()}
  def fetch_returns() do
    {:ok, Returner.Cache.fetch_returns()}
  end

  def portfolio_tickers, do: @portfolio_tickers

  def index_ticker, do: @index_ticker
end
