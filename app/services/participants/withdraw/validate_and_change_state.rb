# frozen_string_literal: true

module Participants
  module Withdraw
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, inclusion: { in: reasons }
        validate :not_already_withdrawn
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile,
                                          state: ParticipantProfileState.states[:withdrawn],
                                          cpd_lead_provider:,
                                          reason:)

          user_profile.training_status_withdrawn!
          relevant_induction_record.update!(training_status: "withdrawn", force_training_status_change:) if relevant_induction_record
        end

        unless user_profile.npq?
          induction_coordinator = user_profile.school.induction_coordinator_profiles.first
          SchoolMailer.fip_provider_has_withdrawn_a_participant(withdrawn_participant: user_profile, induction_coordinator:).deliver_later
        end

        user_profile
      end

      def not_already_withdrawn
        return unless user_profile

        if user_profile.ecf?
          errors.add(:induction_record, I18n.t(:invalid_withdrawal)) if relevant_induction_record&.training_status_withdrawn?
        elsif user_profile&.training_status_withdrawn?
          errors.add(:participant_profile, I18n.t(:invalid_withdrawal))
        end
      end
    end
  end
end
