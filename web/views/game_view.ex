defmodule LeagueManager.GameView do
  use LeagueManager.Web, :view

  def games_per_round(games) do
    games
    |> Enum.sort_by(&({&1.round, &1.id}))
    |> Stream.chunk_by(&(&1.round))
    |> Stream.with_index(1)
  end
end
