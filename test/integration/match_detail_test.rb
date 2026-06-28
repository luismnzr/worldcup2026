require "test_helper"

class MatchDetailTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = Tournament.current
    @predictor = create(:user, display_name: "Pedrito")
    create(:entry, :paid, user: @predictor, tournament: @tournament)
    @match = create(:match, :open, number: 73, home_team: "México", away_team: "Argentina")
    create(:prediction, user: @predictor, match: @match, advancing_pick: "México")
    @viewer = create(:user)
  end

  test "requires login" do
    get match_path(@match)
    assert_redirected_to new_user_session_path
  end

  test "hides others' picks before kickoff" do
    sign_in @viewer
    get match_path(@match)

    assert_response :success
    assert_match "Se revelan", response.body
    assert_no_match "Pedrito", response.body
  end

  test "reveals picks once the match is locked" do
    @match.update_columns(kickoff_at: 1.hour.ago) # cierra
    sign_in @viewer
    get match_path(@match)

    assert_response :success
    assert_match "Pedrito", response.body
  end
end
