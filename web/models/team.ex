defmodule LeagueManager.Team do
  use LeagueManager.Web, :model

  schema "teams" do
    field :name, :string
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
    |> validate_required([:name])
    |> unique_constraint(:name, message: "Team name already taken")
  end

  defmodule Record do
    @enforce_keys [:team_id, :team_name]
    defstruct team_id: nil, team_name: nil, wins: 0, losses: 0, draws: 0, goals_for: 0, goals_against: 0, goal_differential: 0, points: 0
  end

  def records do
    query = record_query()
    %{columns: raw_columns, rows: rows} = Ecto.Adapters.SQL.query!(LeagueManager.Repo, query, [])
    columns = Enum.map(raw_columns, &String.to_atom/1)
    rows |> Stream.map(&struct!(Record, Enum.zip(columns, &1)))
  end

  defp record_query do
    """
    SELECT
      records.*,
      records.goals_for - records.goals_against AS goal_differential,
      records.draws + 3 * records.wins AS points
    FROM (
      SELECT
        teams.id AS team_id,
        teams.name AS team_name,
        SUM(CASE WHEN home_games.home_score > home_games.away_score THEN 1 ELSE 0 END) + SUM(CASE WHEN away_games.away_score > away_games.home_score THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN home_games.home_score < home_games.away_score THEN 1 ELSE 0 END) + SUM(CASE WHEN away_games.away_score < away_games.home_score THEN 1 ELSE 0 END) AS losses,
        SUM(CASE WHEN home_games.home_score = home_games.away_score THEN 1 ELSE 0 END) + SUM(CASE WHEN away_games.away_score = away_games.home_score THEN 1 ELSE 0 END) AS draws,
        COALESCE(SUM(home_games.home_score), 0) + COALESCE(SUM(away_games.away_score), 0) AS goals_for,
        COALESCE(SUM(home_games.away_score), 0) + COALESCE(SUM(away_games.home_score), 0) AS goals_against
      FROM teams
      LEFT OUTER JOIN games AS home_games ON teams.id = home_games.home_team_id
      LEFT OUTER JOIN games AS away_games ON teams.id = away_games.away_team_id
      GROUP BY teams.id, teams.name
    ) records
    ORDER BY
      points DESC,
      goal_differential DESC,
      goals_for DESC,
      wins DESC
    """
  end
end
