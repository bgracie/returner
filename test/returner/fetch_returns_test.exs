defmodule Returner.FetchReturnsTest do
  use Returner.DataCase

  describe "build_returns/1" do
    test "builds returns from prices for the given date range" do
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

      expected_returns = %{
        daily_returns: %{
          portfolio_equities: [
            %{
              ticker: "FOO",
              returns: [
                {~D[2001-01-01], Decimal.new("10.0")},
                {~D[2001-01-02], Decimal.new("9.0")},
                {~D[2001-01-03], Decimal.new("8.3")}
              ]
            },
            %{
              ticker: "BAR",
              returns: [
                {~D[2001-01-01], Decimal.new("3.3")},
                {~D[2001-01-02], Decimal.new("3.2")},
                {~D[2001-01-03], Decimal.new("3.1")}
              ]
            }
          ],
          index: %{
            ticker: "BAZ",
            returns: [
              {~D[2001-01-01], Decimal.new("5.0")},
              {~D[2001-01-02], Decimal.new("4.7")},
              {~D[2001-01-03], Decimal.new("4.5")}
            ]
          }
        },
        average_returns: %{
          portfolio: Decimal.new("6.15"),
          index: Decimal.new("4.73")
        }
      }

      date_range = Date.range(~D[2001-01-01], ~D[2001-01-03])
      calculated_returns = Returner.FetchReturns.build_returns(prices, date_range)
      assert calculated_returns == expected_returns
    end
  end
end
