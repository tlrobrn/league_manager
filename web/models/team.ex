defmodule LeagueManager.Team do
  use LeagueManager.Web, :model
  use Arc.Ecto.Schema

  schema "teams" do
    field :name, :string
    field :logo, LeagueManager.Logo.Type
    has_many :players, LeagueManager.Player, on_delete: :nilify_all
    has_many :home_games, LeagueManager.Game, on_delete: :delete_all, foreign_key: :home_team_id
    has_many :away_games, LeagueManager.Game, on_delete: :delete_all, foreign_key: :away_team_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> cast_assoc(:players, required: true)
    |> cast_attachments(params, [:logo])
    |> validate_required([:name])
    |> unique_constraint(:name, message: "Team name already taken")
  end

  def sorted_by_name_with_players do
    __MODULE__
    |> order_by([t], asc: t.name)
    |> preload(:players)
  end

  def games(struct) do
    team = LeagueManager.Repo.preload(struct, [home_games: :away_team, away_games: :home_team])
    home_data = team.home_games
    |> Stream.map(fn game -> {game.round, "vs", game.away_team.name, game.home_score, game.away_score} end)

    away_data = team.away_games
    |> Stream.map(fn game -> {game.round, "@", game.home_team.name, game.away_score, game.home_score} end)

    Stream.concat(home_data, away_data) |> Enum.sort_by(fn {round, _, _, _, _} -> round end)
  end

  defmodule Record do
    @enforce_keys [:team_id, :team_name]
    defstruct team_id: nil, team_name: nil, matches_played: 0, wins: 0, losses: 0, draws: 0, goals_for: 0, goals_against: 0, goal_differential: 0, points: 0
  end

  def record(%__MODULE__{id: id}) do
    records() |> Enum.find(&(&1.team_id == id))
  end

  def records do
    query = record_query()
    %{columns: raw_columns, rows: rows} = Ecto.Adapters.SQL.query!(LeagueManager.Repo, query, [])
    columns = Enum.map(raw_columns, &String.to_atom/1)
    rows |> Stream.map(&struct!(Record, Enum.zip(columns, &1)))
  end

  def records_with_teams do
    records = records()
    team_ids = records |> Enum.map(&(&1.team_id))
    teams = __MODULE__
    |> where([t], t.id in ^team_ids)
    |> LeagueManager.Repo.all
    |> Stream.map(&({&1.id, &1}))
    |> Enum.into(%{})

    records
    |> Stream.map(fn record -> {teams[record.team_id], record} end)
  end

  defp record_query do
    """
    WITH home_records AS (
      SELECT
        teams.id,
        COUNT(games.id) AS matches_played,
        SUM(CASE WHEN games.home_score > games.away_score THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN games.home_score < games.away_score THEN 1 ELSE 0 END) AS losses,
        SUM(CASE WHEN games.home_score = games.away_score THEN 1 ELSE 0 END) AS draws,
        SUM(games.home_score) AS goals_for,
        SUM(games.away_score) AS goals_against,
        SUM(games.home_score - games.away_score) AS goal_differential
      FROM teams
      INNER JOIN games ON teams.id = games.home_team_id AND games.home_score IS NOT NULL
      GROUP BY teams.id
    ),
    away_records AS (
      SELECT
        teams.id,
        COUNT(games.id) AS matches_played,
        SUM(CASE WHEN games.away_score > games.home_score THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN games.away_score < games.home_score THEN 1 ELSE 0 END) AS losses,
        SUM(CASE WHEN games.away_score = games.home_score THEN 1 ELSE 0 END) AS draws,
        SUM(games.away_score) AS goals_for,
        SUM(games.home_score) AS goals_against,
        SUM(games.away_score - games.home_score) AS goal_differential
      FROM teams
      INNER JOIN games ON teams.id = games.away_team_id AND games.away_score IS NOT NULL
      GROUP BY teams.id
    )
    SELECT
      teams.id AS team_id,
      teams.name AS team_name,
      COALESCE(home_records.matches_played, 0) + COALESCE(away_records.matches_played, 0) AS matches_played,
      COALESCE(home_records.wins, 0) + COALESCE(away_records.wins, 0) AS wins,
      COALESCE(home_records.losses, 0) + COALESCE(away_records.losses, 0) AS losses,
      COALESCE(home_records.draws, 0) + COALESCE(away_records.draws, 0) AS draws,
      COALESCE(home_records.goals_for, 0) + COALESCE(away_records.goals_for, 0) AS goals_for,
      COALESCE(home_records.goals_against, 0) + COALESCE(away_records.goals_against, 0) AS goals_against,
      COALESCE(home_records.goal_differential, 0) + COALESCE(away_records.goal_differential, 0) AS goal_differential,
      COALESCE(home_records.draws, 0) + COALESCE(away_records.draws, 0) + 3 * (COALESCE(home_records.wins, 0) + COALESCE(away_records.wins, 0)) AS points
    FROM teams
    LEFT OUTER JOIN home_records ON teams.id = home_records.id
    LEFT OUTER JOIN away_records ON teams.id = away_records.id
    ORDER BY
      points DESC,
      goal_differential DESC,
      goals_for DESC,
      wins DESC
    """
  end
end
