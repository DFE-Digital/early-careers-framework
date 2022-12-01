# frozen_string_literal: true

module Analytics
  class ECFInductionService
    class << self
      def upsert_record(induction_record)
        return unless %w[test development production].include? Rails.env

        record = Analytics::ECFInduction.find_or_initialize_by(induction_record_id: induction_record.id)
        participant_profile = induction_record.participant_profile

        record.external_id = participant_profile.participant_identity.external_identifier
        record.participant_profile_id = participant_profile.id
        record.induction_programme_id = induction_record.induction_programme_id
        record.induction_programme_type = induction_record.induction_programme.training_programme
        record.school_name = induction_record.school.name
        record.school_urn = induction_record.school.urn
        record.schedule_id = induction_record.schedule_id
        record.mentor_id = induction_record.mentor_profile&.participant_identity&.external_identifier if participant_profile.ect?
        record.appropriate_body_id = induction_record.customized_appropriate_body_id
        record.appropriate_body_name = induction_record.customized_appropriate_body&.name
        record.start_date = induction_record.start_date
        record.end_date = induction_record.end_date
        record.induction_status = induction_record.induction_status
        record.training_status = induction_record.training_status
        record.school_transfer = induction_record.school_transfer
        record.cohort_id = induction_record&.cohort&.id
        record.user_id = participant_profile.user_id
        record.participant_type = participant_profile.type

        record.save!
      end
    end
  end
end
