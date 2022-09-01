# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeTrainingStatusForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      REASON_OPTIONS = {
        "deferred" => Participants::Defer::ECF.reasons,
        "withdrawn" => Participants::Withdraw::ECF.reasons,
      }.freeze

      attribute :participant_profile
      attribute :training_status
      attribute :reason

      validates :training_status, inclusion: ParticipantProfile.training_statuses.values
      validates :reason, inclusion: { in: :valid_training_status_reasons }, if: :reason_required?

      def training_status_options
        ParticipantProfile.training_statuses.except(current_training_status)
      end

      def reason_required?
        training_status.present? && training_status != "active"
      end

      def reason_options
        REASON_OPTIONS.except(current_training_status)
      end

      def current_training_status
        participant_profile.state
      end

      def valid_training_status_reasons
        reason_options[training_status]
      end

      def action_class_name
        case training_status
        when "active"
          "Resume"
        when "deferred"
          "Defer"
        when "withdrawn"
          "Withdraw"
        end
      end

      def save
        return false unless valid?

        return true if status_unchanged?

        klass = "Participants::#{action_class_name}::NPQ".constantize
        klass.call(
          params: {
            cpd_lead_provider: participant_profile.npq_application.npq_lead_provider.cpd_lead_provider,
            course_identifier: participant_profile.npq_application.npq_course.identifier,
            participant_id: participant_profile.participant_identity.external_identifier,
            reason:,
            force_training_status_change: true,
          },
        )

        true
      end

    private

      def status_unchanged?
        training_status == current_training_status
      end
    end
  end
end
