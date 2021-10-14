module RecordDeclarations
  module Actions
    class MakeDeclarationsEligibleForParticipant
      class << self
        def call(participant:)
          participant.participant_declarations.submitted.each(&:make_eligible!)
        end
      end
    end
  end
end
