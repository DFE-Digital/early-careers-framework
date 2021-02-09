# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    admin_only
  end

  def create?
    admin_only
  end

  def update?
    admin_only
  end

  def permitted_attributes
    if user.admin?
      %i[full_name email]
    end
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.where(id: user.id)
    end
  end
end
