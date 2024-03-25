# frozen_string_literal: true

# This service doesn't have any  protections against triggering the mailers
# multiple times. Does it need a safeguard to send each mailer only once?
module Admin
  class DailyEmailSchedulesProcessor < BaseService
    attr_reader :email_schedules

    def initialize
      @email_schedules = EmailSchedule.to_send_today
    end

    def call
      email_schedules.find_each do |email_schedule|
        email_schedule.sending!

        emails_sent = BulkMailers::SchoolReminderComms
          .new(cohort: Cohort.current, email_schedule:)
          .send(email_schedule.mailer_method)

        email_schedule.update!(status: :sent, emails_sent_count: emails_sent.to_i)
      end
    end
  end
end
