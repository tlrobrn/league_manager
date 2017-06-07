defmodule LeagueManager.Repo.Migrations.AddTeamLogo do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :logo, :string
    end
  end
end
