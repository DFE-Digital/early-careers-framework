# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_email_factory, class: "EmailSchedule") do
    mailer_name { EmailSchedule::MAILERS.keys.sample.to_s }
    scheduled_at { 1.week.from_now }
    status { "queued" }

    trait(:scheduled_for_today) do
      scheduled_at { Date.current }
      status { "queued" }
    end

    trait(:sending) do
      scheduled_at { Date.current }
      status { "sending" }
    end

    trait(:sent) do
      scheduled_at { 1.month.ago }
      status { "sent" }
    end

    trait(:valid) {}

    after(:build) do
      Rails.logger.debug("created email schedule")
    end
  end
end
