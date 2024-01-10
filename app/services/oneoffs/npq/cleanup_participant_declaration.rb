# frozen_string_literal: true

module Oneoffs::NPQ
  class CleanupParticipantDeclaration
    def migrate
      ActiveRecord::Base.transaction do
        incorrect_participant_declarations.in_batches.each_record do |declaration|
          if declaration.user.participant_identities.empty? && declaration.participant_profile.user.participant_identities.map(&:external_identifier).include?(declaration.user.id)
            declaration.update!(user_id: declaration.participant_profile.user.id)
          end
        end
      end
    end

  private

    def incorrect_participant_declarations
      ParticipantDeclaration::NPQ.joins(participant_profile: :participant_identity).where("participant_declarations.user_id != participant_identities.user_id")
    end
  end
end
