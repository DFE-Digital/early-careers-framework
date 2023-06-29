# frozen_string_literal: true

class InductionRecordPolicy < ApplicationPolicy
  def show?
    admin?
  end

  def edit?
    admin?
  end

  def edit_appropriate_body?
    return true if admin?

    school_induction_coordinator? && (record.current? || record.transferring_in?)
  end

  def edit_email?
    return true if admin?

    school_induction_coordinator? && (record.current? || record.transferring_in?)
  end

  def edit_mentor?
    return true if admin?

    school_induction_coordinator? && (record.current? || record.transferring_in?)
  end

  def edit_name?
    return true if admin?

    school_induction_coordinator? && record.current?
  end

  def validate?
    admin?
  end

  def change_preferred_email?
    super_user_only
  end

  alias_method :update_appropriate_body?, :edit_appropriate_body?
  alias_method :update_email?, :edit_email?
  alias_method :update_mentor?, :edit_mentor?
  alias_method :update_name?, :edit_name?

  alias_method :edit_preferred_email?, :change_preferred_email?
  alias_method :update_preferred_email?, :change_preferred_email?

  alias_method :withdraw_record?, :destroy?
  alias_method :remove?, :destroy?

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      return scope.none unless user.induction_coordinator?

      scope.where(induction_programme_id: InductionProgramme.joins(:school_cohort).where(school_cohort: { school: user.schools }).select(:id))
    end
  end

private

  def school_induction_coordinator?
    user.school_ids.include?(record.school_id)
  end
end
