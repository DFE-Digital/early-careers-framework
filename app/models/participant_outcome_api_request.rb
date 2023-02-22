# frozen_string_literal: true

class ParticipantOutcomeApiRequest < ApplicationRecord
  belongs_to :participant_outcome, class_name: "ParticipantOutcome::NPQ"

  scope :trn_not_found, -> { where(status_code: [404]).where("response_body @> ?", { errorCode: 10_001 }.to_json) }
end
