# frozen_string_literal: true

class ParticipantProfilePolicy < ApplicationPolicy
  def show?
    admin?
  end

  def validate?
    admin?
  end

  def change_cohort?
    super_user_only
  end

  def edit_induction_status?
    super_user_only
  end

  alias_method :edit_cohort?, :change_cohort?
  alias_method :confirm_induction_status?, :edit_induction_status?
  alias_method :update_cohort?, :change_cohort?

  alias_method :withdraw_record?, :destroy?
  alias_method :remove?, :destroy?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.where(id: InductionRecord.joins(:school).where(school: { id: user.schools.select(:id) }).select(:participant_profile_id))
    end
  end
end
