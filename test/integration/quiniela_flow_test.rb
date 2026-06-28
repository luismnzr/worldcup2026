require "test_helper"

class QuinielaFlowTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = Tournament.current
  end

  test "public pages render" do
    get root_path
    assert_response :success

    get bracket_path
    assert_response :success

    get bracket_path(view: "todos")
    assert_response :success

    get leaderboard_path
    assert_response :success
  end

  test "predictions are gated behind a paid entry" do
    user = create(:user)
    sign_in user

    get predictions_path
    assert_redirected_to new_entry_path
  end

  test "full flow: paid entry -> predict -> admin records result -> points & propagation" do
    player = create(:user, display_name: "El Crack")
    create(:entry, :paid, user: player, tournament: @tournament)

    # Partido R32 con equipos cargados a mano por el admin.
    source = Match.find_or_create_by!(number: 73) do |m|
      m.stage = "r32"
    end
    source.update!(home_team: "México", away_team: "Argentina", kickoff_at: 2.days.from_now, status: "scheduled")

    # Siguiente partido que se alimenta del 73.
    dependent = Match.find_or_create_by!(number: 90) do |m|
      m.stage = "r16"
    end
    dependent.update!(home_source_number: 73, home_source_result: "winner", home_team: nil, away_team: nil)

    # El jugador entra a predicciones y guarda su pick.
    sign_in player
    get predictions_path
    assert_response :success

    post prediction_path(source), params: { prediction: { advancing_pick: "México", home_score: 2, away_score: 1 } }
    prediction = player.predictions.find_by(match: source)
    assert_equal "México", prediction.advancing_pick

    # El admin captura el resultado.
    admin = create(:user, :admin)
    sign_in admin
    patch record_result_admin_match_path(source), params: { match: { home_score: 2, away_score: 1, advancing_team: "México" } }
    assert_redirected_to admin_matches_path

    # Puntos otorgados (r32 = 1) + bonus de marcador exacto (1) = 2.
    assert_equal 2, prediction.reload.points_awarded
    # Propagación: México avanza al partido 90.
    assert_equal "México", dependent.reload.home_team
    # Leaderboard incluye al jugador inscrito.
    rankings = LeaderboardService.rankings(@tournament)
    assert_equal player, rankings.first.user
    assert_equal 2, rankings.first.points
  end
end
