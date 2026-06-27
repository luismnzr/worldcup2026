require "test_helper"

class ResultsSyncServiceTest < ActiveSupport::TestCase
  setup { Tournament.current }

  def fixture(home:, away:, fh:, fa:, winner:, status: "FINISHED", stage: "LAST_16", duration: "REGULAR")
    {
      "status" => status, "stage" => stage,
      "homeTeam" => { "name" => home }, "awayTeam" => { "name" => away },
      "score" => { "winner" => winner, "duration" => duration, "fullTime" => { "home" => fh, "away" => fa } }
    }
  end

  test "applies a finished match using English API names" do
    match = create(:match, :open, stage: "r16", home_team: "México", away_team: "Argentina")
    payload = { "matches" => [ fixture(home: "Mexico", away: "Argentina", fh: 2, fa: 1, winner: "HOME_TEAM") ] }

    summary = ResultsSyncService.call(payload)

    match.reload
    assert_equal "finished", match.status
    assert_equal 2, match.home_score
    assert_equal 1, match.away_score
    assert_equal "México", match.advancing_team
    assert_equal [ match.number ], summary.applied
  end

  test "orients the score to our home/away even if the API has them swapped" do
    match = create(:match, :open, home_team: "México", away_team: "Argentina")
    # API trae Argentina como local
    payload = { "matches" => [ fixture(home: "Argentina", away: "Mexico", fh: 3, fa: 0, winner: "HOME_TEAM") ] }

    ResultsSyncService.call(payload)

    match.reload
    assert_equal 0, match.home_score, "México (nuestro local) anotó 0"
    assert_equal 3, match.away_score, "Argentina (nuestro visitante) anotó 3"
    assert_equal "Argentina", match.advancing_team
  end

  test "resolves the advancing team on a penalty shootout via winner" do
    match = create(:match, :open, home_team: "Brasil", away_team: "Croacia")
    payload = { "matches" => [ fixture(home: "Brazil", away: "Croatia", fh: 1, fa: 1, winner: "AWAY_TEAM", duration: "PENALTY_SHOOTOUT") ] }

    ResultsSyncService.call(payload)
    assert_equal "Croacia", match.reload.advancing_team
  end

  test "propagates the winner to the next match" do
    source = create(:match, :open, number: 73, home_team: "México", away_team: "Argentina")
    dependent = create(:match, number: 90, stage: "r16", home_source_number: 73, home_source_result: "winner",
                       home_team: nil, away_team: nil)
    payload = { "matches" => [ fixture(home: "Mexico", away: "Argentina", fh: 2, fa: 1, winner: "HOME_TEAM", stage: "LAST_32") ] }

    ResultsSyncService.call(payload)
    assert_equal "México", dependent.reload.home_team
  end

  test "skips group-stage fixtures" do
    match = create(:match, :open, home_team: "México", away_team: "Argentina")
    payload = { "matches" => [ fixture(home: "Mexico", away: "Argentina", fh: 2, fa: 1, winner: "HOME_TEAM", stage: "GROUP_STAGE") ] }

    summary = ResultsSyncService.call(payload)
    assert_empty summary.applied
    assert_equal "scheduled", match.reload.status
  end

  test "skips fixtures whose teams are not in our bracket yet" do
    payload = { "matches" => [ fixture(home: "Spain", away: "Germany", fh: 1, fa: 0, winner: "HOME_TEAM") ] }
    summary = ResultsSyncService.call(payload)
    assert_empty summary.applied
  end

  test "does not clobber a match already finished (manual override wins)" do
    match = create(:match, :finished, home_team: "México", away_team: "Argentina",
                   home_score: 5, away_score: 0, advancing_team: "México")
    payload = { "matches" => [ fixture(home: "Mexico", away: "Argentina", fh: 1, fa: 1, winner: "AWAY_TEAM") ] }

    summary = ResultsSyncService.call(payload)
    assert_empty summary.applied
    assert_equal 5, match.reload.home_score
    assert_equal "México", match.advancing_team
  end

  test "records unresolved team names" do
    create(:match, :open, home_team: "México", away_team: "Argentina")
    payload = { "matches" => [ fixture(home: "Wakanda", away: "Narnia", fh: 1, fa: 0, winner: "HOME_TEAM") ] }

    summary = ResultsSyncService.call(payload)
    assert_empty summary.applied
    assert_equal 1, summary.unresolved.size
  end

  test "only finished fixtures are applied" do
    match = create(:match, :open, home_team: "México", away_team: "Argentina")
    payload = { "matches" => [ fixture(home: "Mexico", away: "Argentina", fh: 0, fa: 0, winner: nil, status: "IN_PLAY") ] }

    summary = ResultsSyncService.call(payload)
    assert_empty summary.applied
    assert_equal "scheduled", match.reload.status
  end
end
