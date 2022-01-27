# frozen_string_literal: true

module Participants
  module Withdraw
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, inclusion: { in: reasons }
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile, state: ParticipantProfileState.states[:withdrawn], reason: reason)
          user_profile.training_status_withdrawn!
        end

        unless user_profile.npq?
          induction_coordinator = user_profile.school.induction_coordinator_profiles.first
          SchoolMailer.fip_provider_has_withdrawn_a_participant(withdrawn_participant: user_profile, induction_coordinator: induction_coordinator).deliver_later
        end

        user_profile
      end
    end
  end
end
