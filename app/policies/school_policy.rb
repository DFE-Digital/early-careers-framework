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

      if FeatureFlag.active?(:cohortless_dashboard) && user.induction_coordinator?
        return scope.where(id: user.schools.select(:id))
      end

      scope.none
    end
  end
end
