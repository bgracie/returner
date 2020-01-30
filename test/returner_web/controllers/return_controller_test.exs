defmodule ReturnerWeb.ReturnControllerTest do
  use ReturnerWeb.ConnCase

  test "GET /returns", %{conn: conn} do
    conn = get(conn, "/returns")
    page = html_response(conn, 200)

    assert page =~ "Past Year Returns"
    assert elem_exists?(page, "#returns-chart")
    assert elem_exists?(page, "#portfolio-average-return")
    assert elem_exists?(page, "#index-average-return")
  end

  defp elem_exists?(page, query) do
    results =
      page
      |> Floki.parse_document()
      |> elem(1)
      |> Floki.find(query)

    length(results) > 0
  end
end
