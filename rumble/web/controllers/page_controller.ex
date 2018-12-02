defmodule Rumble.PageController do
  use Rumble.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
