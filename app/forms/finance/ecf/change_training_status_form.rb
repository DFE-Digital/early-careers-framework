# frozen_string_literal: true

module Finance
  module ECF
    class ChangeTrainingStatusForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      REASON_OPTIONS = {
        "deferred" => ParticipantProfile::DEFERRAL_REASONS,
        "withdrawn" => ParticipantProfile::ECF::WITHDRAW_REASONS,
      }.freeze

      attribute :participant_profile
      attribute :training_status
      attribute :reason
      attribute :induction_record

      validates :training_status, inclusion: ParticipantProfile.training_statuses.values
      validates :reason, inclusion: { in: :valid_training_status_reasons }, if: :reason_required?

      def training_status_options
        ParticipantProfile.training_statuses.except(current_training_status)
      end

      def reason_options
        REASON_OPTIONS.except(current_training_status)
      end

      def current_training_status
        induction_record&.training_status
      end

      def save
        return false unless valid?
        return true if status_unchanged?

        params = {
          cpd_lead_provider:,
          course_identifier:,
          participant_id: participant_profile.participant_identity.external_identifier,
          relevant_induction_record: induction_record,
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

      def cpd_lead_provider
        @cpd_lead_provider ||= induction_record.lead_provider.cpd_lead_provider
      end

      def course_identifier
        @course_identifier ||=
          case participant_profile.participant_type
          when :mentor
            "ecf-mentor"
          when :ect
            "ecf-induction"
          end
      end

      def status_unchanged?
        training_status == current_training_status
      end
    end
  end
end
