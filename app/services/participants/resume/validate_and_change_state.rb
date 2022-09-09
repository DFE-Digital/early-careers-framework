# frozen_string_literal: true

module Participants
  module Resume
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        validate :not_already_active
        validate :not_already_withdrawn, unless: :force_training_status_change
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile, state: ParticipantProfileState.states[:active], cpd_lead_provider:)
          user_profile.training_status_active!
          relevant_induction_record.update!(training_status: "active", force_training_status_change:) if relevant_induction_record
        end

        user_profile
      end

      def not_already_active
        return unless user_profile

        if user_profile.ecf?
          errors.add(:induction_record, I18n.t(:already_active)) if relevant_induction_record&.training_status_active?
        elsif user_profile.training_status_active?
          errors.add(:participant_profile, I18n.t(:already_active))
        end
      end

      def not_already_withdrawn
        return unless user_profile

        if user_profile.ecf?
          errors.add(:induction_record, I18n.t(:invalid_resume)) if relevant_induction_record&.training_status_withdrawn?
        elsif user_profile.training_status_withdrawn?
          errors.add(:participant_profile, I18n.t(:invalid_resume))
        end
      end
    end
  end
end
