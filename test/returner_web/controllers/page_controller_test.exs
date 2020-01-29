defmodule ReturnerWeb.PageControllerTest do
  use ReturnerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) =~ Routes.return_path(conn, :index)
  end
end
