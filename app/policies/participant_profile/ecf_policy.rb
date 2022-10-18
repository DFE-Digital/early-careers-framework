# frozen_string_literal: true

class ParticipantProfile::ECFPolicy < ParticipantProfilePolicy
  def show?
    admin? || (user.induction_coordinator? && same_school?)
  end

  alias_method :edit_mentor?, :show?
  alias_method :update_mentor?, :show?

  def update?
    return true if admin?
    return false if record.contacted_for_info?

    user.induction_coordinator? && same_school?
  end

  alias_method :update_name?, :update?
  alias_method :edit_name?, :update?
  alias_method :update_email?, :update?
  alias_method :edit_email?, :update?
  alias_method :add_appropriate_body?, :update?
  alias_method :appropriate_body_type?, :update?
  alias_method :update_appropriate_body_type?, :update?
  alias_method :appropriate_body?, :update?
  alias_method :update_appropriate_body?, :update?

  def update_start_term?
    return true if admin?
    return false if record.participant_declarations.any?

    user.induction_coordinator? && same_school?
  end

  def update_validation_data?
    admin? && record.training_status_active? && (record.ecf_participant_eligibility.blank? || !record.ecf_participant_eligibility.eligible_status?)
  end

  alias_method :edit_start_term?, :update_start_term?

  def withdraw_record?
    return false if record.participant_declarations.not_voided.any?
    return false unless user.induction_coordinator? || admin?
    return false if record.completed_validation_wizard? && !record.ecf_participant_eligibility&.ineligible_status?

    admin? || same_school?
  end

  alias_method :remove?, :withdraw_record?
  alias_method :destroy?, :withdraw_record?

private

  def same_school?
    if FeatureFlag.active?(:change_of_circumstances)
      InductionRecord.joins(:school)
        .where(school: { id: user.induction_coordinator_profile.schools.select(:id) })
        .where(participant_profile_id: record.id)
        .any?
    else
      user.induction_coordinator_profile.schools.include?(record.school)
    end
  end
end
