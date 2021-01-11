# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create?
    return true if user.admin?

    false
  end

  def update?
    return true if user.admin?

    false
  end

  def permitted_attributes
    if user.admin?
      %i[first_name last_name email]
    end
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.where(id: user.id)
    end
  end
end
