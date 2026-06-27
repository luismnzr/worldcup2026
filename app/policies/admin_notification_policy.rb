# frozen_string_literal: true

class AdminNotificationPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def mark_as_read?
    admin?
  end

  def mark_one_read?
    admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
