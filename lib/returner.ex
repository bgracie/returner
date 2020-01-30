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
end
