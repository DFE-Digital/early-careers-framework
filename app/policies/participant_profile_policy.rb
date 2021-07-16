# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.includes(school_cohort: :school).where(school_cohort: { school: user.induction_coordinator_profile.schools })
    end
  end
end
