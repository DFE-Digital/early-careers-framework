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
        }

        case training_status
        when "deferred"
          DeferParticipant.new(params.merge(reason:)).call
        when "active"
          ResumeParticipant.new(params).call
        else
          klass = "Participants::#{action_class_name}::#{participant_class_name}".constantize
          klass.call(
            params: params.merge(reason:, force_training_status_change: true),
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

      def participant_class_name
        case participant_profile.participant_type
        when :ect
          "EarlyCareerTeacher"
        when :mentor
          "Mentor"
        else
          raise "Participant type not recognised"
        end
      end

      def action_class_name
        case training_status
        when "active"
          "Resume"
        else
          raise "training_status type not recognised"
        end
      end

      # this is not correct because a participant may changeable induction records
      # with different lead provider. But due to the participant drilldown not being
      # correct we will make the assumpion that we will change it on the latest induction record
      # regarless of the lead provider
      def cpd_lead_provider
        @cpd_lead_provider ||= participant_profile.induction_records.latest.lead_provider.cpd_lead_provider
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

      def induction_record
        @induction_record ||= participant_profile&.induction_records&.latest
      end

      def status_unchanged?
        training_status == current_training_status
      end
    end
  end
end
