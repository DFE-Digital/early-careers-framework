# frozen_string_literal: true

class ParticipantOutcomeApiRequest < ApplicationRecord
  belongs_to :participant_outcome, class_name: "ParticipantOutcome::NPQ"
end
