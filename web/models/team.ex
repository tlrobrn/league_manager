defmodule LeagueManager.Team do
  use LeagueManager.Web, :model

  schema "teams" do
    field :name, :string
    has_many :players, LeagueManager.Player, on_delete: :nilify_all

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
end
