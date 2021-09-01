# frozen_string_literal: true

module Analytics
  class ValidationService
    class << self
      def upsert_record(participant_profile)
        return unless %w[development staging production].include? Rails.env

        record = Analytics::ECFParticipant.find_or_initialize_by(participant_profile_id: participant_profile.id)
        record.user_id = participant_profile.user.id
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

        record.save!
      end

      def record_validation(participant_profile:, real_time_attempts:, real_time_success:, nino_entered:)
        return unless %w[development staging production].include? Rails.env

        record = Analytics::ECFParticipant.find_or_initialize_by(participant_profile_id: participant_profile.id)
        record.real_time_attempts = real_time_attempts
        record.real_time_success = real_time_success
        record.nino_entered = nino_entered
        record.trn_verified = trn_verified?(participant_profile)
        record.eligible_for_funding = eligible_for_funding?(participant_profile)
        record.validation_submitted_at = Time.zone.now

        record.save!
      end
      handle_asynchronously :record_validation

    private

      def eligible_for_funding?(participant_profile)
        true if participant_profile.ecf_participant_eligibility&.eligible_status?
        # TODO: CPDRP-672 make this false when it's possible for someone to be confirmed not eligible
      end

      def trn_verified?(participant_profile)
        participant_profile.ecf_participant_eligibility.present?
      end
    end
  end
end
