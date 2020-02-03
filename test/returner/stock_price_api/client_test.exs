defmodule Returner.StockPriceApi.ClientTest do
  use Returner.DataCase

  describe "fetch_equity_prices/2" do
    @tag :external
    test "fetches equity prices for a given ticker and date range" do
      date_range = Date.range(~D[2019-01-02], ~D[2019-01-03])
      result = Returner.StockPriceApi.Client.fetch_equity_prices("MSFT", date_range)

      expected_result = %{
        prices: [
          {~D[2019-01-03], Money.new("97.4000", :USD)},
          {~D[2019-01-02], Money.new("101.1200", :USD)}
        ],
        ticker: "MSFT"
      }

      assert result == expected_result
    end
  end
end
