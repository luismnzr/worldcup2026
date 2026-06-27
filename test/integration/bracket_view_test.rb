require "test_helper"

class BracketViewTest < ActionDispatch::IntegrationTest
  test "shows the signed-in user's pick and the venue on a match" do
    tournament = Tournament.current
    user = create(:user)
    create(:entry, :paid, user: user, tournament: tournament)
    match = create(:match, :open, number: 73, venue: "Monterrey", home_team: "México", away_team: "Argentina")
    create(:prediction, user: user, match: match, advancing_pick: "México")

    sign_in user
    get bracket_path

    assert_response :success
    assert_match "Monterrey", response.body
    assert_match "Tu pick", response.body
  end

  test "does not leak picks to anonymous visitors" do
    user = create(:user)
    create(:entry, :paid, user: user, tournament: Tournament.current)
    match = create(:match, :open, number: 73, venue: "Monterrey", home_team: "México", away_team: "Argentina")
    create(:prediction, user: user, match: match, advancing_pick: "México")

    get bracket_path

    assert_response :success
    assert_match "Monterrey", response.body
    assert_no_match "Tu pick", response.body
  end
end
