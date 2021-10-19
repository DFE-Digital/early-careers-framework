# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakeDeclarationsEligibleForParticipantProfile
      class << self
        def call(participant_profile:)
          participant_profile.participant_declarations.submitted.each(&:make_eligible!)
        end
      end
    end
  end
end
