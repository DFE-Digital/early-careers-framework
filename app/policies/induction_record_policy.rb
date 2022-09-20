# frozen_string_literal: true

class InductionRecordPolicy < ApplicationPolicy
  def show?
    admin?
  end

  def edit?
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

      scope.where(induction_programme_id: InductionProgramme.joins(:school_cohort).where(school_cohort: { school: user.schools }).select(:id))
    end
  end
end
