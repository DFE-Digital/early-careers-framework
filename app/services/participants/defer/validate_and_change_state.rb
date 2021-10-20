# frozen_string_literal: true

module Participants
  module Defer
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, inclusion: { in: reasons }
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile, state: ParticipantProfileState.states[:deferred], reason: reason)
          user_profile.training_status_deferred!
        end
        user_profile
      end
    end
  end
end
