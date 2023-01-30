# frozen_string_literal: true

module Analytics
  class ECFValidationService
    class << self
      def upsert_record(participant_profile)
        return unless %w[test development production].include? Rails.env

        record = Analytics::ECFParticipant.find_or_initialize_by(participant_profile_id: participant_profile.id)
        record.user_id = participant_profile.user.id
        record.external_id = participant_profile.participant_identity.external_identifier
        record.user_created_at = participant_profile.user.created_at
        record.trn_verified = trn_verified?(participant_profile)
        record.school_urn = participant_profile.school_cohort.school.urn
        record.school_name = participant_profile.school_cohort.school.name
        record.establishment_phase_name = participant_profile.school_cohort.school.school_phase_name
        record.participant_type = participant_profile.type
        record.cohort = participant_profile.school_cohort.cohort.start_year
        record.mentor_id = participant_profile.mentor_id if participant_profile.ect?
        record.manually_validated = participant_profile.ecf_participant_eligibility&.manually_validated
        record.eligible_for_funding = eligible_for_funding?(participant_profile)
        record.validation_submitted_at ||= participant_profile.ecf_participant_validation_data&.created_at
        record.active = participant_profile.active_record?
        record.sparsity = participant_profile.sparsity_uplift
        record.pupil_premium = participant_profile.pupil_premium_uplift
        record.training_status = training_status_for(participant_profile)
        record.schedule_identifier = participant_profile.schedule&.schedule_identifier

        record.save!
      end

      def record_validation(participant_profile:, real_time_attempts:, real_time_success:, nino_entered:)
        return unless %w[test development production].include? Rails.env

        record = Analytics::ECFParticipant.find_or_initialize_by(participant_profile_id: participant_profile.id)
        record.real_time_attempts = real_time_attempts
        record.real_time_success = real_time_success
        record.nino_entered = nino_entered
        record.trn_verified = trn_verified?(participant_profile)
        record.eligible_for_funding = eligible_for_funding?(participant_profile)
        record.validation_submitted_at = Time.zone.now

        record.save!
      end

    private

      def eligible_for_funding?(participant_profile)
        return true if participant_profile.ecf_participant_eligibility&.eligible_status?

        false if participant_profile.ecf_participant_eligibility&.ineligible_status?
      end

      def trn_verified?(participant_profile)
        participant_profile.ecf_participant_eligibility.present?
      end

      def training_status_for(participant_profile)
        participant_profile&.latest_induction_record&.training_status.presence || participant_profile.training_status
      end
    end
  end
end
