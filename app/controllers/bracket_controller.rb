class BracketController < ApplicationController
  include TournamentAccess

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @matches_by_stage = Match.ordered.group_by(&:stage)
  end
end
