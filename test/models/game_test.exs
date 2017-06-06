defmodule LeagueManager.GameTest do
  use LeagueManager.ModelCase

  alias LeagueManager.Game

  @valid_attrs %{away_score: 42, home_score: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Game.changeset(%Game{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Game.changeset(%Game{}, @invalid_attrs)
    refute changeset.valid?
  end
end
