require "test_helper"
require "ostruct"

class AdminMatchesReferenceTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    sign_in @admin
  end

  test "reference page lists API knockout fixtures with translated names" do
    payload = {
      "matches" => [
        { "stage" => "LAST_32", "utcDate" => "2026-06-28T19:00:00Z", "status" => "TIMED",
          "homeTeam" => { "name" => "South Africa" }, "awayTeam" => { "name" => "Canada" } },
        { "stage" => "GROUP_STAGE", "utcDate" => "2026-06-11T19:00:00Z", "status" => "FINISHED",
          "homeTeam" => { "name" => "Mexico" }, "awayTeam" => { "name" => "Brazil" } }
      ]
    }
    fake = OpenStruct.new
    fake.define_singleton_method(:configured?) { true }
    fake.define_singleton_method(:world_cup_matches) { payload }

    FootballDataClient.stub(:new, fake) do
      get reference_admin_matches_path
    end

    assert_response :success
    assert_match "Sudáfrica", response.body   # South Africa → canónico
    assert_match "Canadá", response.body
    assert_no_match "Brazil", response.body    # la fase de grupos se excluye
  end

  test "reference redirects when the API token is not configured" do
    fake = OpenStruct.new
    fake.define_singleton_method(:configured?) { false }

    FootballDataClient.stub(:new, fake) do
      get reference_admin_matches_path
    end

    assert_redirected_to admin_matches_path
  end
end
