# frozen_string_literal: true

class ParticipantProfile::ECFPolicy < ParticipantProfilePolicy
  def show?
    admin? || (user.induction_coordinator? && (same_school? || mentoring_at_school?))
  end

  alias_method :edit_mentor?, :show?
  alias_method :update_mentor?, :show?

  def new_ect?
    record.mentor? && show?
  end
  alias_method :add_ect?, :new_ect?

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
  alias_method :appropriate_body_confirmation?, :update?
  alias_method :update_appropriate_body?, :update?

  def update_validation_data?
    return true if super_user?

    admin? && record.training_status_active? && (record.ecf_participant_eligibility.blank? || !record.eligible?)
  end

  def withdraw_record?
    return false if record.participant_declarations.not_voided.any?
    return false unless user.induction_coordinator? || admin?
    return false if record.completed_validation_wizard? && !record.ineligible?

    admin? || same_school?
  end

  alias_method :remove?, :withdraw_record?
  alias_method :destroy?, :withdraw_record?

private

  def same_school?
    InductionRecord.joins(:school)
      .where(school: { id: sit_school_ids })
      .where(participant_profile_id: record.id)
      .any?
  end

  def mentoring_at_school?
    record.mentor? && sit_school_ids.intersect?(mentor_school_ids)
  end

  def sit_school_ids
    user.induction_coordinator_profile.schools.select(:id).map(&:id)
  end

  def mentor_school_ids
    record.school_mentors.select(:school_id).map(&:school_id)
  end
end
