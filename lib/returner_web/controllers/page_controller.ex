defmodule ReturnerWeb.PageController do
  use ReturnerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
