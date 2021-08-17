# frozen_string_literal: true

FactoryBot.define do
  factory :schedule, class: "Finance::Schedule" do
    name { "ECF September standard 2021" }
    after(:create) do |schedule|
      [Date.new(2021, 9, 1), Date.new(2021, 11, 1), Date.new(2022, 2, 1)].each do |start_date|
        create(
          :milestone,
          schedule: schedule,
          start_date: start_date,
          milestone_date: start_date + 1.month,
          payment_date: start_date + 2.months,
        )
      end
    end
  end
end
