require "test_helper"

class PredictionTest < ActiveSupport::TestCase
  test "valid prediction on an open match" do
    assert build(:prediction).valid?
  end

  test "cannot create a prediction on a locked match" do
    match = create(:match, :locked)
    prediction = build(:prediction, match: match, advancing_pick: "México")
    assert_not prediction.valid?
  end

  test "cannot create a prediction before teams are known" do
    match = create(:match, home_team: nil, away_team: nil, kickoff_at: 2.days.from_now)
    assert_not build(:prediction, match: match, advancing_pick: "México").valid?
  end

  test "advancing_pick must be one of the two teams" do
    assert_not build(:prediction, advancing_pick: "Brasil").valid?
  end

  test "cannot change pick after the match locks" do
    prediction = create(:prediction)
    prediction.match.update_column(:kickoff_at, 1.hour.ago)
    prediction.reload.advancing_pick = "Argentina"
    assert_not prediction.valid?
  end

  test "points recalculation is allowed even after lock" do
    prediction = create(:prediction)
    prediction.match.update_column(:kickoff_at, 1.hour.ago)
    assert_nothing_raised { prediction.update_column(:points_awarded, 5) }
  end

  test "computed_points awards stage points for a correct pick" do
    match = create(:match, :finished) # México avanza, marcador 2-1, r32
    prediction = create_prediction_for(match, advancing_pick: "México")
    assert_equal 1, prediction.computed_points
  end

  test "computed_points is zero for a wrong pick" do
    match = create(:match, :finished)
    prediction = create_prediction_for(match, advancing_pick: "Argentina")
    assert_equal 0, prediction.computed_points
  end

  test "exact score hit adds the configured bonus on top" do
    match = create(:match, :finished) # 2-1 México
    prediction = create_prediction_for(match, advancing_pick: "México", home_score: 2, away_score: 1)
    assert prediction.exact_score_hit?
    assert_equal 3, prediction.computed_points(exact_score_bonus: 2) # 1 (r32) + 2 (bonus)
  end

  test "wrong scoreline gets no bonus" do
    match = create(:match, :finished) # 2-1
    prediction = create_prediction_for(match, advancing_pick: "México", home_score: 3, away_score: 0)
    assert_not prediction.exact_score_hit?
    assert_equal 1, prediction.computed_points(exact_score_bonus: 2)
  end

  private

  # Crea la predicción antes de que el partido se "termine" para evitar el lock.
  def create_prediction_for(match, **attrs)
    match.update_columns(status: "scheduled", kickoff_at: 2.days.from_now, home_score: nil, away_score: nil, advancing_team: nil)
    prediction = create(:prediction, match: match, **attrs)
    match.update_columns(status: "finished", kickoff_at: 2.hours.ago, home_score: 2, away_score: 1, advancing_team: "México")
    prediction.reload
  end
end
