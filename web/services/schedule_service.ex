defmodule LeagueManager.ScheduleService do
  alias LeagueManager.{Game, Repo, Team}
  require IEx

  def create_schedule do
    [pinned_team | teams] = Team |> Repo.all
    teams = pad_teams(teams)
    rounds = length(teams)

    Repo.transaction fn ->
      schedule_games(pinned_team, teams, 1, rounds)
      schedule_games(pinned_team, teams, 1, rounds, rounds)
    end
  end

  defp pad_teams(teams) when rem(length(teams), 2) == 0, do: [nil | teams]
  defp pad_teams(teams), do: teams

  defp schedule_games(pinned_team, teams, round, max_round, offset \\ 0)
  defp schedule_games(_, _, round, max_round,_ ) when round > max_round, do: nil
  defp schedule_games(pinned_team, teams, round, max_round, offset) do
    away_first = (rem(round + offset, 2) == 1)
    [tribute | pool] = teams
    create_game({pinned_team, tribute}, round + offset, away_first)

    [top, bottom] = Enum.chunk(pool, div(length(pool), 2))
    bottom = Enum.reverse(bottom)
    Stream.zip(top, bottom) |> Enum.map(&create_game(&1, round + offset, away_first))

    schedule_games(pinned_team, pool ++ [tribute], round + 1, max_round, offset)
  end

  defp create_game({nil, _}, _, _), do: nil
  defp create_game({_, nil}, _, _), do: nil
  defp create_game({home_team, away_team}, round, false) do
    %Game{}
    |> Game.changeset(%{home_team: home_team, away_team: away_team, round: round})
    |> Repo.insert!
  end
  defp create_game({away_team, home_team}, round, true) do
    %Game{}
    |> Game.changeset(%{home_team: home_team, away_team: away_team, round: round})
    |> Repo.insert!
  end
end
