defmodule LeagueManager.GameController do
  use LeagueManager.Web, :controller
  alias LeagueManager.Game

  def index(conn, _params) do
    games = Repo.all(Game) |> Repo.preload([:home_team, :away_team])
    render(conn, "index.html", games: games)
  end

  def edit(conn, %{"id" => id}) do
    game = Repo.get!(Game, id) |> Repo.preload([:home_team, :away_team])
    changeset = Game.changeset(game)
    render(conn, "edit.html", game: game, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Repo.get!(Game, id) |> Repo.preload([:home_team, :away_team])
    changeset = Game.changeset(game, game_params)

    case Repo.update(changeset) do
      {:ok, _game} ->
        conn
        |> put_flash(:info, "Scores updated")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", game: game, changeset: changeset)
    end
  end
end
