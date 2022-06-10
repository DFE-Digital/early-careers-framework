# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakeDeclarationsEligibleForParticipantProfile
      class << self
        def call(participant_profile:)
          ApplicationRecord.transaction do
            participant_profile.participant_declarations.submitted.each do |participant_declaration|
              participant_declaration.make_eligible!
              Finance::DeclarationStatementAttacher.new(participant_declaration).call
            end
          end
        end
      end
    end
  end
end
