class PoolController < ApplicationController
  include TournamentAccess

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def home
    @next_matches = Match.where(status: "scheduled").where.not(kickoff_at: nil)
                         .where("kickoff_at > ?", Time.current).ordered.limit(5)
    @participants_count = current_tournament.participants_count
  end
end
