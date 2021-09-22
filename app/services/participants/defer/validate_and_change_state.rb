# frozen_string_literal: true

module Participants
  module Defer
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, presence: true
        validates :reason, inclusion: { in: reasons }, allow_blank: true
      end

      def perform_action!
        ParticipantProfileState.create!(participant_profile: user_profile, state: "deferred", reason: reason)
        user_profile
      end
    end
  end
end
