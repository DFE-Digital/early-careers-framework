# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeTrainingStatusForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      REASON_OPTIONS = {
        "deferred" => ParticipantProfile::DEFERRAL_REASONS,
        "withdrawn" => ParticipantProfile::NPQ::WITHDRAW_REASONS,
      }.freeze

      attribute :participant_profile
      attribute :training_status
      attribute :reason

      validates :training_status, inclusion: ParticipantProfile.training_statuses.values
      validates :reason, inclusion: { in: :valid_training_status_reasons }, if: :reason_required?
      validate :do_not_defer_if_without_declarations

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
          participant_id: participant_profile.participant_identity.user_id,
        }

        case training_status
        when "deferred"
          DeferParticipant.new(params.merge(reason:)).call
        when "active"
          ResumeParticipant.new(params).call
        when "withdrawn"
          WithdrawParticipant.new(params.merge(reason:)).call
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

      def status_unchanged?
        training_status == current_training_status
      end

      def do_not_defer_if_without_declarations
        return unless training_status == "deferred"
        return unless participant_profile&.npq?
        return unless participant_profile.npq_application.accepted?

        if participant_profile.participant_declarations.empty?
          errors.add(:training_status, :invalid_deferral_no_declarations)
        end
      end
    end
  end
end
