# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      user.managed_participant_profiles
    end
  end
end
