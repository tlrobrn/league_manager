defmodule LeagueManager.TeamView do
  use LeagueManager.Web, :view

  alias LeagueManager.{Player, Team}

  def player_names(%Team{players: players}) do
    players
    |> Stream.map(&display_name/1)
    |> Enum.join(", ")
  end

  defp display_name(%Player{first_name: first_name, last_name: last_name}) do
    "#{String.first(first_name)}. #{last_name}"
  end
end
