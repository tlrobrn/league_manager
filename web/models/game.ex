defmodule LeagueManager.Game do
  use LeagueManager.Web, :model

  schema "games" do
    field :home_score, :integer
    field :away_score, :integer
    belongs_to :home_team, LeagueManager.Team
    belongs_to :away_team, LeagueManager.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:home_score, :away_score])
    |> validate_required([:home_score, :away_score])
  end
end
