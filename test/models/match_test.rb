require "test_helper"

class MatchTest < ActiveSupport::TestCase
  test "predictable only when both teams known and kickoff in the future" do
    assert build(:match, :open).predictable?
    assert_not build(:match, home_team: nil, away_team: nil, kickoff_at: 2.days.from_now).predictable?
    assert_not build(:match, :locked).predictable?, "kickoff in the past is not predictable"
  end

  test "locked at kickoff_at" do
    assert build(:match, :open).locked? == false
    assert build(:match, :locked).locked?
    assert build(:match, kickoff_at: nil).locked?, "no kickoff means locked"
  end

  test "points_for_correct uses the per-stage weights" do
    assert_equal 1, build(:match, stage: "r32").points_for_correct
    assert_equal 2, build(:match, stage: "r16").points_for_correct
    assert_equal 3, build(:match, stage: "qf").points_for_correct
    assert_equal 5, build(:match, stage: "sf").points_for_correct
    assert_equal 3, build(:match, stage: "third").points_for_correct
    assert_equal 8, build(:match, stage: "final").points_for_correct
  end

  test "other_team returns the opponent" do
    match = build(:match, :open) # México vs Argentina
    assert_equal "Argentina", match.other_team("México")
    assert_equal "México", match.other_team("Argentina")
    assert_nil match.other_team("Brasil")
  end
end
