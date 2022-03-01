# frozen_string_literal: true

class InductionRecordPolicy < ApplicationPolicy
  def show?
    admin?
  end

  def validate?
    admin?
  end

  alias_method :withdraw_record?, :destroy?
  alias_method :remove?, :destroy?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.where(school_cohort_id: SchoolCohort.where(school: user.schools).select(:id))
    end
  end
end
