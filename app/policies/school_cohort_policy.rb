# frozen_string_literal: true

class SchoolCohortPolicy < ApplicationPolicy
  def show?
    return true if user.admin?
    return false unless user.induction_coordinator_profile

    user.induction_coordinator_profile.school_ids.include?(record.school_id)
  end

  alias update? show?
  alias info? update?
  alias edit? update?
  alias success? update?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.where(
        school_id: School.joins(:induction_coordinator_profiles)
          .where(induction_coordinator_profiles: { user_id: user.id })
          .select(:id)
      )
    end
  end
end
