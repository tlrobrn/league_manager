defmodule LeagueManager.Game do
  use LeagueManager.Web, :model
  alias LeagueManager.Repo

  schema "games" do
    field :home_score, :integer
    field :away_score, :integer
    field :round, :integer
    belongs_to :home_team, LeagueManager.Team
    belongs_to :away_team, LeagueManager.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:home_score, :away_score, :round])
    |> attach_assoc(params, [:home_team, :away_team])
    |> validate_required([:round])
    |> check_constraint(:home_score, name: :positive_home_score, message: "Must be greater than or equal to 0")
    |> check_constraint(:away_score, name: :positive_away_score, message: "Must be greater than or equal to 0")
    |> check_constraint(:round, name: :positive_round, message: "Must be greater than 0")
  end

  def current_round do
    case Repo.one(current_round_query()) do
      nil -> nil
      %{round: round} -> round
    end
  end

  defp current_round_query do
    __MODULE__
    |> where([g], is_nil(g.home_score))
    |> or_where([g], is_nil(g.away_score))
    |> select([g], %{round: min(g.round)})
  end

  def current_games do
    __MODULE__
    |> join(:inner, [g], r in subquery(current_round_query()), g.round == r.round)
    |> order_by([g, r], [g.round, g.id])
    |> preload(:home_team)
    |> preload(:away_team)
    |> Repo.all
  end

  defp attach_assoc(changeset, _params, []), do: changeset
  defp attach_assoc(changeset, params, [key | keys]) do
    assoc = Map.get(params, key) || Map.get(params, Atom.to_string(key))
    changeset = case assoc do
      nil -> changeset
      struct -> put_assoc(changeset, key, struct)
    end

    attach_assoc(changeset, params, keys)
  end
end
