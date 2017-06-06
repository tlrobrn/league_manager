defmodule LeagueManager.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :first_name, :string
      add :last_name, :string
      add :team_id, references(:teams, on_delete: :nilify_all)

      timestamps()
    end
    create index(:players, [:team_id])
    create unique_index(:players, [:first_name, :last_name], name: :players_full_name_index)

  end
end
