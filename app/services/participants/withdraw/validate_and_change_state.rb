# frozen_string_literal: true

module Participants
  module Withdraw
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, presence: true
        validates :reason, inclusion: { in: reasons }, allow_blank: true
      end

      def perform_action!
        ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn", reason: reason)
        user_profile.update!(training_status: "withdrawn")
        user_profile
      end
    end
  end
end
