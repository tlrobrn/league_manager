defmodule LeagueManager.TeamView do
  use LeagueManager.Web, :view

  alias LeagueManager.{Player, Team}

  def first_player(%Team{players: [player, _]}) do
    display_name(player)
  end

  def second_player(%Team{players: [_, player]}) do
    display_name(player)
  end

  defp display_name(%Player{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end
end
