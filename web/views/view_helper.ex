defmodule LeagueManager.ViewHelper do
  def image_url(team = %LeagueManager.Team{logo: logo}) do
    case LeagueManager.Logo.url({logo, team}) do
      nil -> ""
      url ->
        uri = url |> URI.parse
        [bucket, path] = uri.path |> String.trim_leading("/") |> String.split("/", parts: 2)
        %URI{uri | path: "/" <> path, host: bucket <> "." <> uri.host} |> URI.to_string
    end
  end

  def first_player(%LeagueManager.Team{players: [player, _]}) do
    display_name(player)
  end

  def second_player(%LeagueManager.Team{players: [_, player]}) do
    display_name(player)
  end

  defp display_name(%LeagueManager.Player{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end
end
