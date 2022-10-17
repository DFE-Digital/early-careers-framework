# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeTrainingStatusForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      REASON_OPTIONS = {
        "deferred" => ParticipantProfile::DEFERRAL_REASONS,
        "withdrawn" => Participants::Withdraw::NPQ.reasons,
      }.freeze

      attribute :participant_profile
      attribute :training_status
      attribute :reason

      validates :training_status, inclusion: ParticipantProfile.training_statuses.values
      validates :reason, inclusion: { in: :valid_training_status_reasons }, if: :reason_required?

      def training_status_options
        ParticipantProfile.training_statuses.except(current_training_status)
      end

      def reason_options
        REASON_OPTIONS.except(current_training_status)
      end

      def current_training_status
        participant_profile.state
      end

      def save
        return false unless valid?
        return true if status_unchanged?

        params = {
          cpd_lead_provider: participant_profile.npq_application.npq_lead_provider.cpd_lead_provider,
          course_identifier: participant_profile.npq_application.npq_course.identifier,
          participant_id: participant_profile.participant_identity.external_identifier,
          reason:,
        }

        if training_status == "deferred"
          DeferParticipant.new(params).call
        else
          klass = "Participants::#{action_class_name}::NPQ".constantize
          klass.call(
            params: params.merge(force_training_status_change: true),
          )
        end

        true
      end

    private

      def reason_required?
        training_status.present? && training_status != "active"
      end

      def valid_training_status_reasons
        reason_options[training_status] || []
      end

      def action_class_name
        case training_status
        when "active"
          "Resume"
        when "withdrawn"
          "Withdraw"
        else
          raise "training_status type not recognised"
        end
      end

      def status_unchanged?
        training_status == current_training_status
      end
    end
  end
end
