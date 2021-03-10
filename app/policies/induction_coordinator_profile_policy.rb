# frozen_string_literal: true

class InductionCoordinatorProfilePolicy < ApplicationPolicy
  def show?
    admin_only
  end

  def index?
    admin_only
  end

  def destroy?
    admin_only
  end

  def permitted_attributes
    if user.admin?
      :id
    end
  end

  class Scope < Scope
    def resolve
      return scope.kept if user.admin?

      scope.none
    end
  end
end
