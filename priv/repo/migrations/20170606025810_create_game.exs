defmodule LeagueManager.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :home_score, :integer
      add :away_score, :integer
      add :home_team_id, references(:teams, on_delete: :delete_all)
      add :away_team_id, references(:teams, on_delete: :delete_all)

      timestamps()
    end
    create index(:games, [:home_team_id])
    create index(:games, [:away_team_id])
    create constraint(:games, :positive_home_score, check: "home_score > 0")
    create constraint(:games, :positive_away_score, check: "away_score > 0")

  end
end
