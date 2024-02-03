# frozen_string_literal: true

class EmailSchedule < ApplicationRecord
  MAILERS = {
    assign_a_mentor_to_each_ect: :contact_sits_that_need_to_assign_mentors,
    register_ects_and_mentors: :contact_sits_that_have_not_added_participants,
    contract_with_a_training_provider: :contact_sits_that_have_chosen_fip_but_not_partnered,
  }.freeze

  validates :mailer_name, inclusion: { in: MAILERS.keys.map(&:to_s) }
  validates :scheduled_at, presence: true
  validate :validate_future_schedule_date, if: -> { scheduled_at_changed? }
  validate :valdate_one_schedule_per_day, if: -> { scheduled_at_changed? }

  enum status: {
    queued: "queued",
    sending: "sending",
    sent: "sent",
  }

  scope :to_send_today, -> { queued.where(scheduled_at: ..Date.current) }

private

  def validate_future_schedule_date
    errors.add(:scheduled_at, "The schedule date must be in the future") unless scheduled_at&.future?
  end

  def valdate_one_schedule_per_day
    if scheduled_at.present?
      existing_record = EmailSchedule.where("DATE(scheduled_at) = ?", scheduled_at.to_date).limit(1).first

      if existing_record
        errors.add(:scheduled_at, "Only one mailer is allowed per day")
      end
    end
  end
end
