# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_npq_course, class: "NPQCourse") do
    name { "NPQ Leading Teaching (#{SecureRandom.hex(6)})" }

    trait(:valid) {}

    after(:build) do
      Rails.logger.debug("Built an NPQ application")
    end
  end
end
