defmodule LeagueManager.Repo.Migrations.AddGameRound do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :round, :integer, null: false
    end
    create constraint(:games, :positive_round, check: "round > 0")
    create index(:games, :round)
  end
end
