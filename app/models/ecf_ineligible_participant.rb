# frozen_string_literal: true

class ECFIneligibleParticipant < ApplicationRecord

  enum reason: {
    previous_participant: "previous_participant",
    previous_induction: "previous_induction",
  }

end
