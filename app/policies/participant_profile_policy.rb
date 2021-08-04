# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  def show?
    admin?
  end

  def validate?
    admin?
  end

  def destroy?
    admin? && (record.ect? || record.mentor?)
  end

  alias_method :remove?, :delete?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.where(school_cohort_id: SchoolCohort.where(school: user.schools).select(:id))
    end
  end
end
