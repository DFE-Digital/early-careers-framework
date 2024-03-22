# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_email_factory, class: "EmailSchedule") do
    mailer_name { EmailSchedule::MAILERS.keys.sample.to_s }
    scheduled_at { rand(1..10).weeks.from_now }
    status { "queued" }

    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait(:scheduled_for_today) do
      scheduled_at { Date.current }
      status { "queued" }

      skip_validations
    end

    trait(:sending) do
      scheduled_at { Date.current }
      status { "sending" }

      skip_validations
    end

    trait(:sent) do
      scheduled_at { 1.month.ago }
      status { "sent" }
      actual_email_count { rand(15_000) }

      skip_validations
    end

    after(:build) do
      Rails.logger.debug("created email schedule")
    end
  end
end
