# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :school_cohort

  enum status: {
    todo: "TO DO",
    done: "DONE",
    on_hold: "CANNOT START YET",
  }
end
