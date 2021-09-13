# frozen_string_literal: true

class ECFIneligibleParticipant < ApplicationRecord
  enum reason: {
    previous_participation: "previous_participation",
    previous_induction: "previous_induction",
  }
end
