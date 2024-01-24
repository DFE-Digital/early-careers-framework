# frozen_string_literal: true

class EmailSchedule < ApplicationRecord
  MAILERS = {
    assign_a_mentor_to_each_ect: :contact_sits_that_need_to_assign_mentors,
    register_ects_and_mentors: :contact_sits_that_have_not_added_participants,
    contract_with_a_training_provider: :contact_sits_that_have_chosen_fip_but_not_partnered,
  }.freeze

  validates :mailer_name, inclusion: { in: MAILERS.keys.map(&:to_s) }
  validates :scheduled_at, presence: true

  enum status: {
    queued: "queued",
    sending: "sending",
    sent: "sent",
  }

  scope :to_send_today, -> { queued.where(scheduled_at: ..Date.current) }
end
