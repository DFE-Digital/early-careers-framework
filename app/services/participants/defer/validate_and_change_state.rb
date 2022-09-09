# frozen_string_literal: true

module Participants
  module Defer
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, inclusion: { in: reasons }
        validate :not_already_withdrawn, unless: :force_training_status_change
        validate :not_already_deferred
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile, state: ParticipantProfileState.states[:deferred], cpd_lead_provider:, reason:)
          user_profile.training_status_deferred!

          relevant_induction_record.update!(training_status: "deferred", force_training_status_change:) if relevant_induction_record
        end

        user_profile
      end

      def not_already_withdrawn
        return unless user_profile

        if user_profile.ecf?
          errors.add(:induction_record, I18n.t(:invalid_withdrawal)) if relevant_induction_record&.training_status_withdrawn?
        elsif user_profile.training_status_withdrawn?
          errors.add(:participant_profile, I18n.t(:invalid_withdrawal))
        end
      end

      def not_already_deferred
        return unless user_profile

        if user_profile.ecf?
          errors.add(:induction_record, I18n.t(:invalid_deferral)) if relevant_induction_record&.training_status_deferred?
        elsif user_profile.training_status_deferred?
          errors.add(:participant_profile, I18n.t(:invalid_deferral))
        end
      end
    end
  end
end
