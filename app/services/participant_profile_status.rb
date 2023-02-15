# frozen_string_literal: true

class ParticipantProfileStatus
  def initialize(participant_profile:, induction_record:)
    @participant_profile = participant_profile
    @induction_record = induction_record
  end

  def status_name
    return unless participant_profile

    if training_status_withdrawn?
      "no_longer_being_trained"

    elsif eligible? && participant_profile.single_profile?
      "training_or_eligible_for_training"

    elsif eligible? && participant_profile.primary_profile?
      "training_or_eligible_for_training"

    elsif ineligible? && mentor_with_duplicate_profile?
      "training_or_eligible_for_training"

    elsif participant_has_no_qts?
      "checking_qts"

    elsif participant_profile.manual_check_needed?
      "dfe_checking_eligibility"

    elsif nqt_plus_one? && ineligible?
      "not_eligible_for_funded_training"

    elsif ineligible? && mentor_was_in_early_rollout? && on_fip?
      "training_or_eligible_for_training"

    elsif ineligible? && mentor_was_in_early_rollout?
      "training_or_eligible_for_training"

    elsif ineligible?
      "not_eligible_for_funded_training"

    elsif latest_email&.delivered?
      "contacted_for_information"

    elsif latest_email&.failed?
      "contacted_for_information"

    else
      "contacted_for_information"
    end
  end

  def is_status?(status)
    status == status_name
  end

  def self.status_options
    %w[
      contacted_for_information
      dfe_checking_eligibility
      checking_qts
      training_or_eligible_for_training
      no_longer_being_trained
      not_eligible_for_funded_training
    ].index_with do |o|
      I18n.t("participant_profile_status.status.#{o}.title")
    end
  end

private

  attr_reader :participant_profile, :induction_record

  delegate :school_cohort, to: :participant_profile

  def latest_email
    @latest_email ||= Email.associated_with(participant_profile).tagged_with(:request_for_details).latest
  end

  def eligible?
    participant_profile.eligible_status?
  end

  def ineligible?
    participant_profile.ineligible_status?
  end

  def mentor_was_in_early_rollout?
    return unless participant_profile.mentor?

    participant_profile.previous_participation?
  end

  def mentor_with_duplicate_profile?
    return unless participant_profile.mentor?

    participant_profile.duplicate?
  end

  def on_fip?
    school_cohort&.full_induction_programme?
  end

  def nqt_plus_one?
    participant_profile.previous_induction?
  end

  def participant_has_no_qts?
    participant_profile.no_qts?
  end

  def training_status_withdrawn?
    induction_record.present? ? induction_record.training_status_withdrawn? : participant_profile.training_status_withdrawn?
  end
end
