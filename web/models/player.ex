defmodule LeagueManager.Player do
  use LeagueManager.Web, :model

  schema "players" do
    field :first_name, :string
    field :last_name, :string
    belongs_to :team, LeagueManager.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
    |> unique_constraint(:last_name, name: :players_full_name_index, message: "Player already exists")
  end
end
