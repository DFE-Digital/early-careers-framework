# frozen_string_literal: true

module Participants
  module Defer
    module ValidateAndChange
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason
        validates :reason, presence: true
        validates :reason, inclusion: { in: reasons, case_sensitive: false }, allow_blank: true
      end

      def action!
        ParticipantProfileState.create!(participant_profile: user_profile, state: "deferred", reason: reason)
        user_profile
      end
    end
  end
end
