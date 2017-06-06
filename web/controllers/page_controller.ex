defmodule LeagueManager.PageController do
  use LeagueManager.Web, :controller

  def index(conn, _params) do
    records = LeagueManager.Team.records()
    render conn, "index.html", records: records
  end
end
