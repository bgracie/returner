defmodule ReturnerWeb.PageController do
  use ReturnerWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.return_path(conn, :index))
  end
end
