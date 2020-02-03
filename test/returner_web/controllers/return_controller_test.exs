defmodule ReturnerWeb.ReturnControllerTest do
  use ReturnerWeb.ConnCase

  import Mock

  describe "GET /returns" do
    test "it shows the returns chart and the average returns", %{conn: conn} do
      with_mock Returner.StockPriceApi.Client,
        fetch_equity_prices: &Returner.StockPriceApi.Client.Mock.fetch_equity_prices/2 do
        conn = get(conn, "/returns")
        page = html_response(conn, 200)

        assert page =~ "Past Year Returns"
        assert elem_exists?(page, "#returns-chart")
        assert elem_exists?(page, "#portfolio-average-return")
        assert elem_exists?(page, "#index-average-return")
      end
    end
  end

  defp elem_exists?(page, query) do
    results =
      page
      |> Floki.parse_document()
      |> elem(1)
      |> Floki.find(query)

    length(results) > 0
  end

  describe "build_chart_data/1" do
    test "builds chart data from daily returns" do
      daily_returns = build_sample_daily_returns()

      expected_chart_data = [
        %{
          name: "BAZ",
          data: [
            {~D[2001-01-01], Decimal.new("2.1")},
            {~D[2001-01-02], Decimal.new("3")},
            {~D[2001-01-03], Decimal.new("3")}
          ]
        },
        %{
          name: "FOO",
          data: [
            {~D[2001-01-01], Decimal.new("1")},
            {~D[2001-01-02], Decimal.new("4")},
            {~D[2001-01-03], Decimal.new("5")}
          ]
        },
        %{
          name: "BAR",
          data: [
            {~D[2001-01-01], Decimal.new("2.1")},
            {~D[2001-01-02], Decimal.new("3")},
            {~D[2001-01-03], Decimal.new("3")}
          ]
        }
      ]

      assert ReturnerWeb.ReturnController.build_chart_data(daily_returns) == expected_chart_data
    end
  end

  defp build_sample_daily_returns do
    %{
      portfolio_equities: [
        %{
          ticker: "FOO",
          returns: [
            {~D[2001-01-01], Decimal.new("1")},
            {~D[2001-01-02], Decimal.new("4")},
            {~D[2001-01-03], Decimal.new("5")}
          ]
        },
        %{
          ticker: "BAR",
          returns: [
            {~D[2001-01-01], Decimal.new("2.1")},
            {~D[2001-01-02], Decimal.new("3")},
            {~D[2001-01-03], Decimal.new("3")}
          ]
        }
      ],
      index: %{
        ticker: "BAZ",
        returns: [
          {~D[2001-01-01], Decimal.new("2.1")},
          {~D[2001-01-02], Decimal.new("3")},
          {~D[2001-01-03], Decimal.new("3")}
        ]
      }
    }
  end
end
