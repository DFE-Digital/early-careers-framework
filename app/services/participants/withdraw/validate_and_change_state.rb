# frozen_string_literal: true

module Participants
  module Withdraw
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      REASONS = %w[
        left-teaching-profession
        moved-school
        mentor-no-longer-being-mentor
        school-left-fip
        other
      ].freeze

      included do
        attr_accessor :reason

        validates :reason, inclusion: { in: REASONS }
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileState.create!(participant_profile: user_profile, state: ParticipantProfileState.states[:withdrawn], reason: reason)
          user_profile.training_status_withdrawn!
        end
        user_profile
      end
    end
  end
end
