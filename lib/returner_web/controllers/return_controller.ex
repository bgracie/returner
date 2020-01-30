defmodule ReturnerWeb.ReturnController do
  use ReturnerWeb, :controller

  def index(conn, _params) do
    chart_data = [
      %{name: "A", data: [[175, 60], [190, 80], [180, 75]]},
      %{name: "B", data: [[175, 70], [190, 90], [180, 95]]}
    ]

    portfolio_average_return = Decimal.new("0.03")
    index_average_return = Decimal.new("0.05")

    render(conn, "index.html",
      chart_data: chart_data,
      portfolio_average_return: portfolio_average_return,
      index_average_return: index_average_return
    )
  end
end
