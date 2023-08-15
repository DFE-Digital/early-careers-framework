# frozen_string_literal: true

require "active_support/testing/time_helpers"

require_relative "mentor_in_training"

module NewSeeds
  module Scenarios
    module Participants
      module Mentors
        class MentorWithNPQApplicationAfterGDPRRequest < NewSeeds::Scenarios::Participants::Mentors::MentorWithNPQApplication
          def build(**mentor_builder_args)
            super(**mentor_builder_args)

            npq_application.user.participant_identities

            self
          end
        end
      end
    end
  end
end
