# frozen_string_literal: true

class CompletionCandidate < ApplicationRecord
  self.primary_key = "participant_profile_id"

  belongs_to :participant_profile
end
