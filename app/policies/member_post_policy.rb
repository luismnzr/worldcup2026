class MemberPostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? && (user&.admin? || user&.has_active_subscription?)
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where("published_at IS NOT NULL AND published_at <= ?", Time.current)
      end
    end
  end
end
