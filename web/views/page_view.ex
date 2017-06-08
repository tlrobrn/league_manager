defmodule LeagueManager.PageView do
  use LeagueManager.Web, :view
  alias LeagueManager.Team.Record

  def league_table(data) do
    [_first, _second, third | _others] = data
    third_place_minimum = get_current_points(third)

    clinched = data |> determine_if_clinched
    eliminated = data
    |> Stream.map(fn record ->
      max_points = get_potential_total_points(record)
      max_points < third_place_minimum
    end)

    Stream.zip(clinched, eliminated)
    |> Stream.zip(data)
  end

  def champion([record | _]) do
    {{team, _}, _} = record
    team
  end

  defp get_current_points({{_team, _potential_points}, %Record{points: points}}), do: points

  defp get_potential_total_points({{_team, potential_points}, %Record{points: points}}), do: potential_points + points

  defp determine_if_clinched(data, prev_points \\ nil, result \\ [])
  defp determine_if_clinched([last], prev_points, result) do
    points = get_current_points(last)
    clinched = points < prev_points
    Enum.reverse([clinched | result])
  end
  defp determine_if_clinched([record, next_record | data], prev_points, result) do
    points = get_current_points(record)
    below_opponent = get_potential_total_points(next_record)
    max_points = get_potential_total_points(record)

    clinched = points > below_opponent && (is_nil(prev_points) || max_points < prev_points)
    determine_if_clinched([next_record | data], points, [clinched | result])
  end
end
