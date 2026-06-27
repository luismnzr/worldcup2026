class SubscriptionPlansController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @plans = SubscriptionPlan.active.ordered
  end
end
