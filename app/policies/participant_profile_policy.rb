# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  def show?
    admin_only
  end

  def destroy?
    admin? && (record.ect? || record.mentor?)
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      school_cohort_ids = SchoolCohort.where(school: user.schools).select(:id)
      scope.where("school_cohort_id IN (?)", school_cohort_ids)
    end
  end
end
