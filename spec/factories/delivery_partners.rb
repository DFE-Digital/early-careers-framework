# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_partner do
    sequence :name do |n|
      "Delivery Partner #{n}"
    end
  end
end
