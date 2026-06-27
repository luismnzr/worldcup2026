class EventRegistrationPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    user.admin? || record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
