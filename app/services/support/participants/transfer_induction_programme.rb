# frozen_string_literal: true

module Support
  module Participants
    class TransferInductionProgramme < Support::BaseService
      class << self
        def call(participant_profile_id:, induction_programme_id:)
          new(participant_profile_id:, induction_programme_id:).call
        end
      end

      attr_reader :participant_profile,
                  :induction_programme,
                  :induction_record
      attr_writer :logger # allow logging to be disabled for specs

      validates :induction_record, presence: true
      validate :validate_induction_programme_school

      def initialize(participant_profile_id:, induction_programme_id:)
        @participant_profile = ParticipantProfile.find_by!(id: participant_profile_id)
        @induction_programme = InductionProgramme.find_by!(id: induction_programme_id)
        @induction_record = participant_profile.latest_induction_record
      end

      def call
        return false unless valid?

        ActiveRecord::Base.transaction do
          Induction::ChangeInductionRecord.call(induction_record:,
                                                changes: { induction_programme: })

          log_message("Induction Programme for #{participant_profile.id} updated to #{induction_programme.id}")
        end
      rescue StandardError => e
        log_error("Rolling back transaction")
        log_error(e.message)
      end

      def dry_run
        ActiveRecord::Base.transaction do
          call

          log_message("Dry run complete")
          log_message("Rolling back changes")

          raise ActiveRecord::Rollback
        end
      end

    private

      def validate_induction_programme_school
        return if induction_programme.school_cohort.school == participant_profile.school_cohort.school

        errors.add(:induction_programme, "must be for the same school as the participant profile")
      end
    end
  end
end
