require "test_helper"

class ResultsSyncServiceTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  setup do
    @tournament = Tournament.current
    @tournament.update!(exact_score_bonus: 2)
  end

  def fx(id:, date:, home:, away:, status: "TIMED", winner: nil, fh: nil, fa: nil, stage: "LAST_32")
    {
      "id" => id, "stage" => stage, "utcDate" => date, "status" => status,
      "homeTeam" => { "name" => home }, "awayTeam" => { "name" => away },
      "score" => { "winner" => winner, "fullTime" => { "home" => fh, "away" => fa } }
    }
  end

  test "fills teams and dates by assigning external_ids per stage in date order" do
    m73 = create(:match, number: 73, stage: "r32", home_team: nil, away_team: nil)
    m74 = create(:match, number: 74, stage: "r32", home_team: nil, away_team: nil)

    payload = { "matches" => [
      fx(id: 200, date: "2026-06-29T20:00:00Z", home: "Brazil", away: "Japan"),       # más tarde
      fx(id: 100, date: "2026-06-28T19:00:00Z", home: "South Africa", away: "Canada") # más temprano
    ] }

    ResultsSyncService.call(payload)

    # El fixture más temprano va al slot de menor número.
    assert_equal 100, m73.reload.external_id
    assert_equal "Sudáfrica", m73.home_team
    assert_equal "Canadá", m73.away_team
    assert_equal 200, m74.reload.external_id
    assert_equal "Brasil", m74.home_team
  end

  test "applies a finished result, sets advancing team and rescores predictions" do
    match = create(:match, number: 73, stage: "r32", home_team: nil, away_team: nil)
    user = create(:user)

    # 1ª sync: llega con equipos (programado a futuro) → permite predecir.
    ResultsSyncService.call({ "matches" => [
      fx(id: 100, date: 3.days.from_now.utc.iso8601, home: "Mexico", away: "Argentina")
    ] })
    prediction = create(:prediction, user: user, match: match.reload, advancing_pick: "México")

    # 2ª sync: el mismo partido ahora finalizó.
    ResultsSyncService.call({ "matches" => [
      fx(id: 100, date: 3.days.from_now.utc.iso8601, home: "Mexico", away: "Argentina",
         status: "FINISHED", winner: "HOME_TEAM", fh: 2, fa: 1)
    ] })

    match.reload
    assert_equal "finished", match.status
    assert_equal "México", match.advancing_team
    assert_equal 2, match.home_score
    assert_equal 1, prediction.reload.points_awarded # r32 = 1
  end

  test "orients score and advancing when API has home/away swapped" do
    match = create(:match, number: 73, stage: "r32", home_team: nil, away_team: nil)
    ResultsSyncService.call({ "matches" => [
      fx(id: 100, date: "2026-06-28T19:00:00Z", home: "Argentina", away: "Mexico",
         status: "FINISHED", winner: "AWAY_TEAM", fh: 0, fa: 3)
    ] })

    match.reload
    assert_equal "Argentina", match.home_team
    assert_equal "México", match.away_team
    assert_equal "México", match.advancing_team
    assert_equal 3, match.away_score
  end

  test "does not clobber a match already finished" do
    match = create(:match, :finished, number: 73, stage: "r32", external_id: 100,
                   home_team: "México", away_team: "Argentina", advancing_team: "México",
                   home_score: 5, away_score: 0)

    ResultsSyncService.call({ "matches" => [
      fx(id: 100, date: "2026-06-28T19:00:00Z", home: "Mexico", away: "Argentina",
         status: "FINISHED", winner: "AWAY_TEAM", fh: 1, fa: 0)
    ] })

    assert_equal 5, match.reload.home_score
    assert_equal "México", match.advancing_team
  end

  test "ignores group-stage fixtures" do
    create(:match, number: 73, stage: "r32", home_team: nil, away_team: nil)
    summary = ResultsSyncService.call({ "matches" => [
      fx(id: 999, date: "2026-06-11T19:00:00Z", home: "Mexico", away: "Brazil", stage: "GROUP_STAGE")
    ] })

    assert_empty summary.filled
    assert_nil Match.find_by(number: 73).external_id
  end

  test "reuses external_id on subsequent syncs without reassigning" do
    m73 = create(:match, number: 73, stage: "r32", home_team: nil, away_team: nil)
    payload = { "matches" => [ fx(id: 100, date: "2026-06-28T19:00:00Z", home: "Mexico", away: "Argentina") ] }

    ResultsSyncService.call(payload)
    ResultsSyncService.call(payload)

    assert_equal 100, m73.reload.external_id
    assert_equal 1, Match.where(external_id: 100).count
  end
end
