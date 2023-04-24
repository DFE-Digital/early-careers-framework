# frozen_string_literal: true

class ECFIneligibleParticipant < ApplicationRecord
  enum reason: {
    previous_participation: "previous_participation",
    previous_induction: "previous_induction",
    previous_induction_and_participation: "previous_induction_and_participation",
  }

  scope :participated, -> { where(reason: %i[previous_participation previous_induction_and_participation]) }
end
