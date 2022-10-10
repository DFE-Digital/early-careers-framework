# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  def show?
    admin?
  end

  def validate?
    admin?
  end

  def school?
    admin?
  end

  def history?
    admin?
  end

  def records?
    admin?
  end

  def cohorts?
    admin?
  end

  def declarations?
    admin?
  end

  def events?
    admin?
  end

  alias_method :withdraw_record?, :destroy?
  alias_method :remove?, :destroy?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      if FeatureFlag.active?(:change_of_circumstances)
        scope.where(id: InductionRecord.joins(:school).where(school: { id: user.schools.select(:id) }).select(:participant_profile_id))
      else
        scope.where(school_cohort_id: SchoolCohort.where(school: user.schools).select(:id))
      end
    end
  end
end
