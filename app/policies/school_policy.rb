# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    return true if admin_only

    if user.induction_coordinator?
      return user.schools.include?(record)
    end

    false
  end

  class Scope < Scope
    def resolve
      return scope.eligible_or_cip_only if user.admin?

      scope.none
    end
  end
end
