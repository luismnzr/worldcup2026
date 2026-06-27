class LeaderboardController < ApplicationController
  include TournamentAccess

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @rankings = LeaderboardService.rankings(current_tournament)
    @participants_count = current_tournament.participants_count
  end
end
