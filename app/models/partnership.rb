# frozen_string_literal: true

class Partnership < ApplicationRecord
  enum status: {
    pending: "pending",
    accepted: "accepted",
    rejected: "rejected",
  }

  enum reason_for_rejection: {
    partnered_with_another_provider: "I have already partnered with a different training provider",
    provider_not_known: "I don't recognise this training provider",
    change_of_mind: "I have changed my mind",
    no_induction: "I'm not doing any inductions this year",
    mistake: "This looks like a mistake",
    other: "Other",
  }, _prefix: :rejected_with

  validates :reason_for_rejection, presence: { message: "Select a reason" }, if: proc { |partnership| partnership.rejected? }

  belongs_to :school
  belongs_to :lead_provider
  belongs_to :cohort
end
