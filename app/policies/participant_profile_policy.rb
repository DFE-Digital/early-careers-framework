# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  def show?
    return true if admin?
  end

  def validate?
    admin?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.where(school_id: user.induction_coordinator_profile.schools.select(:id))
    end
  end
end
