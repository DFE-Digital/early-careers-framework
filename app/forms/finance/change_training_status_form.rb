# frozen_string_literal: true

module Finance
  class ChangeTrainingStatusForm
    include ActiveModel::Model

    TRAINING_STATUS_OPTIONS = ParticipantProfile.defined_enums["training_status"].freeze

    attr_accessor :participant_profile, :training_status, :reason

    validates :training_status, presence: true, inclusion: TRAINING_STATUS_OPTIONS.keys
    validates :reason, inclusion: { in: :valid_training_status_reasons }, if: :reason_required?

    delegate :ecf?, :npq?,
             to: :participant_profile

    def training_status_options
      opts = TRAINING_STATUS_OPTIONS.dup
      opts.delete(current_training_status)
      opts
    end

    def reason_required?
      training_status.present? && training_status != "active"
    end

    def reason_options
      opts =
        if ecf?
          {
            "active" => [],
            "deferred" => Participants::Defer::ECF.reasons,
            "withdrawn" => Participants::Withdraw::ECF.reasons,
          }
        elsif npq?
          {
            "active" => [],
            "deferred" => Participants::Defer::NPQ.reasons,
            "withdrawn" => Participants::Withdraw::NPQ.reasons,
          }
        end

      opts.delete(current_training_status)
      opts
    end

    def current_training_status
      participant_profile.state
    end

    def valid_training_status_reasons
      reason_options[training_status]
    end

    def participant_class_name
      case participant_profile.participant_type
      when :npq
        "NPQ"
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
      when "deferred"
        "Defer"
      when "withdrawn"
        "Withdraw"
      else
        raise "Class name not recognised"
      end
    end

    def cpd_lead_provider
      @cpd_lead_provider ||=
        if ecf?
          participant_profile.school_cohort.school.active_partnerships[0].lead_provider.cpd_lead_provider
        elsif npq?
          participant_profile.npq_application.npq_lead_provider.cpd_lead_provider
        end
    end

    def course_identifier
      @course_identifier ||=
        case participant_profile.participant_type
        when :mentor
          "ecf-mentor"
        when :ect
          "ecf-induction"
        when :npq
          participant_profile.npq_application.npq_course.identifier
        end
    end

    def save
      return false unless valid?

      # Nothing to change if training_status is same
      return true if training_status == current_training_status

      klass = "Participants::#{action_class_name}::#{participant_class_name}".constantize
      klass.call(
        params: {
          cpd_lead_provider:,
          course_identifier:,
          participant_id: participant_profile.participant_identity.external_identifier,
          reason:,
          force_training_status_change: true,
        },
      )

      true
    end
  end
end
