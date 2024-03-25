# frozen_string_literal: true

module Admin::Performance::EmailSchedulesHelper
  def email_schedule_bounced(email_schedule)
    bounced_count = Email.failed.associated_with(email_schedule).count
    sent_count = email_schedule.emails_sent_count

    percentage = calculate_percentage(bounced_count, sent_count)

    "#{bounced_count} (#{percentage}%)"
  end

  def email_schedule_sent(email_schedule)
    pluralize(number_with_delimiter(email_schedule.emails_sent_count), "email")
  end

  def email_schedule_estimated(email_schedule)
    cohort = Cohort.containing_date(email_schedule.scheduled_at)

    estimate_count = BulkMailers::SchoolReminderComms
      .new(cohort:, dry_run: true)
      .send(email_schedule.mailer_method)

    pluralize(number_with_delimiter(estimate_count), "email")
  end

  def calculate_percentage(part, whole)
    return 0 if whole.to_f.zero? # Prevent division by zero

    ((part.to_f / whole) * 100).round(2)
  end
end
