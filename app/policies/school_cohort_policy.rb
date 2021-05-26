# frozen_string_literal: true

class SchoolCohortPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    return true if user.admin?
    return false unless user.induction_coordinator_profile

    user.induction_coordinator_profile.school_ids.include?(record.school_id)
  end

  alias_method :update?, :show?
  alias_method :info?, :update?
  alias_method :edit?, :update?
  alias_method :success?, :update?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.where(
        school_id: School.joins(:induction_coordinator_profiles)
          .where(induction_coordinator_profiles: { user_id: user.id })
          .select(:id),
      )
    end
  end
end
