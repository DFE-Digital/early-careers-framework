# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  def show?
    admin?
  end

  def validate?
    admin?
  end

  def destroy?
    return record.ect? || record.mentor? if admin?
    return false unless user.induction_coordinator?

    user.induction_coordinator_profile.schools.include?(record.school)
  end

  alias_method :remove?, :destroy?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.where(school_cohort_id: SchoolCohort.where(school: user.schools).select(:id))
    end
  end
end
