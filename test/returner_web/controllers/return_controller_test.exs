defmodule ReturnerWeb.ReturnControllerTest do
  use ReturnerWeb.ConnCase

  test "GET /returns", %{conn: conn} do
    conn = get(conn, "/returns")
    assert html_response(conn, 200) =~ "Past Year Returns"
  end
end
