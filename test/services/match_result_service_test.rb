require "test_helper"

class MatchResultServiceTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  setup do
    @tournament = Tournament.current
    @tournament.update!(exact_score_bonus: 2)
  end

  test "records result, marks finished and scores predictions" do
    match = create(:match, :open, stage: "r16") # México vs Argentina, r16 => 2 pts
    winner = create(:user)
    loser  = create(:user)
    p_win = create(:prediction, user: winner, match: match, advancing_pick: "México")
    p_lose = create(:prediction, user: loser, match: match, advancing_pick: "Argentina")

    MatchResultService.record!(match, home_score: 1, away_score: 0, advancing_team: "México")

    assert_equal "finished", match.reload.status
    assert_equal 2, p_win.reload.points_awarded
    assert_equal 0, p_lose.reload.points_awarded
  end

  test "exact score bonus is applied during rescore" do
    match = create(:match, :open, stage: "r32")
    user = create(:user)
    prediction = create(:prediction, user: user, match: match, advancing_pick: "México", home_score: 3, away_score: 2)

    MatchResultService.record!(match, home_score: 3, away_score: 2, advancing_team: "México")

    assert_equal 3, prediction.reload.points_awarded # 1 (r32) + 2 (bonus)
  end

  test "propagates the winner to the next match" do
    source = create(:match, :open, number: 73, stage: "r32") # México vs Argentina
    dependent = create(:match, number: 90, stage: "r16",
                       home_label: "Ganador P73", away_label: "Ganador P75",
                       home_source_number: 73, away_source_number: 75,
                       home_source_result: "winner", away_source_result: "winner",
                       home_team: nil, away_team: nil)

    MatchResultService.record!(source, home_score: 2, away_score: 1, advancing_team: "México")

    assert_equal "México", dependent.reload.home_team
    assert_nil dependent.away_team, "el otro lado sigue esperando su partido fuente"
  end

  test "propagates the loser to the third-place match" do
    semi = create(:match, :open, number: 101, stage: "sf") # México vs Argentina
    third = create(:match, number: 103, stage: "third",
                   home_label: "Perdedor P101", away_label: "Perdedor P102",
                   home_source_number: 101, away_source_number: 102,
                   home_source_result: "loser", away_source_result: "loser",
                   home_team: nil, away_team: nil)
    final = create(:match, number: 104, stage: "final",
                   home_label: "Ganador P101", away_label: "Ganador P102",
                   home_source_number: 101, away_source_number: 102,
                   home_source_result: "winner", away_source_result: "winner",
                   home_team: nil, away_team: nil)

    MatchResultService.record!(semi, home_score: 2, away_score: 1, advancing_team: "México")

    assert_equal "Argentina", third.reload.home_team, "el perdedor va al tercer lugar"
    assert_equal "México", final.reload.home_team, "el ganador va a la final"
  end

  test "rejects an advancing_team that is not in the match" do
    match = create(:match, :open)
    assert_raises(MatchResultService::InvalidResult) do
      MatchResultService.record!(match, home_score: 1, away_score: 0, advancing_team: "Brasil")
    end
  end

  test "broadcasts the leaderboard after recording" do
    match = create(:match, :open)
    create(:prediction, match: match, advancing_pick: "México")

    assert_turbo_stream_broadcasts("leaderboard", count: 1) do
      MatchResultService.record!(match, home_score: 1, away_score: 0, advancing_team: "México")
    end
  end
end
