# frozen_string_literal: true

module Support
  module Participants
    class Reactivate < Support::BaseService
      class << self
        def call(participant_profile_id:)
          new(participant_profile_id:).call
        end
      end

      attr_reader :participant_profile
      attr_writer :logger # allow logging to be disabled for specs

      def initialize(participant_profile_id:)
        @participant_profile = ParticipantProfile::ECF.find_by!(id: participant_profile_id)
      end

      def call
        ActiveRecord::Base.transaction do
          log_message("Updating training_status and induction_status for ParticipantProfile##{participant_profile.id} to active")

          participant_profile.update!(status: :active, training_status: :active)

          status_change_form = Finance::ECF::ChangeTrainingStatusForm.new(
            participant_profile:,
            training_status: "active",
            reason: "other",
            induction_record: participant_profile.latest_induction_record,
          )

          unless status_change_form.save
            raise "Error in Finance::ECF::ChangeTrainingStatusForm: #{status_change_form.errors.full_messages}"
          end

          Induction::ChangeInductionRecord.call(
            induction_record: participant_profile.latest_induction_record,
            changes: { induction_status: :active },
          )

          log_current_state
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

      def log_current_state
        log_message("Induction Record - training_status: #{participant_profile.latest_induction_record.training_status}")
        log_message("Induction Record - induction_status: #{participant_profile.latest_induction_record.induction_status}")

        log_message("Participant Profile - status: #{participant_profile.status}")
        log_message("Participant Profile - training_status: #{participant_profile.training_status}")
      end
    end
  end
end
