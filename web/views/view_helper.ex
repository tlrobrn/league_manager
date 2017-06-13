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
end
