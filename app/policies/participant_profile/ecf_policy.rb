# frozen_string_literal: true

class ParticipantProfile::ECFPolicy < ParticipantProfilePolicy
  def show?
    admin? || (user.induction_coordinator? && same_school?)
  end

  def withdraw_record?
    return false if record.participant_declarations.where.not(state: :voided).any?
    return true if admin?
    return false unless user.induction_coordinator?
    return false if record.completed_validation_wizard? && !record.ecf_participant_eligibility&.ineligible_status?

    same_school?
  end

  alias_method :remove?, :withdraw_record?
  alias_method :destroy?, :withdraw_record?

private

  def same_school?
    user.induction_coordinator_profile.schools.include?(record.school)
  end
end
