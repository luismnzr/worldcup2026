class MemberPostsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @posts = MemberPost.published.ordered
  end

  def show
    @post = MemberPost.published.find_by!(slug: params[:id])

    unless current_user&.has_active_subscription?
      redirect_to subscription_plans_path,
                  alert: "Necesitas una membresía activa para leer este contenido."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to member_posts_path, alert: "Contenido no disponible."
  end
end
