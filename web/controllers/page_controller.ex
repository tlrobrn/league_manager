defmodule LeagueManager.PageController do
  use LeagueManager.Web, :controller

  def index(conn, _params) do
    records = LeagueManager.Team.records_with_teams_and_potential_points() |> Enum.to_list
    [{{_team, _potential_points}, %{points: points}} | _] = records
    games = LeagueManager.Game.current_games()
    render conn, "index.html", records: records, games: games, target_points: points
  end

  def schedule(conn, _params) do
    LeagueManager.ScheduleService.create_schedule()
    redirect(conn, to: page_path(conn, :index))
  end

  def about(conn, _params) do
    render conn, "about.html"
  end

  def rules(conn, _params) do
    render conn, "rules.html"
  end
end
