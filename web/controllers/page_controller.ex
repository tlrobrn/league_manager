defmodule LeagueManager.PageController do
  use LeagueManager.Web, :controller

  def index(conn, _params) do
    records = LeagueManager.Team.records()
    games = LeagueManager.Game.current_games()
    render conn, "index.html", records: records, games: games
  end

  def schedule(conn, _params) do
    LeagueManager.ScheduleService.create_schedule()
    redirect(conn, to: page_path(conn, :index))
  end

  def about(conn, _params) do
    render conn, "about.html"
  end
end
