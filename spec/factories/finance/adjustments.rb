# frozen_string_literal: true

FactoryBot.define do
  factory :adjustment, class: "Finance::Adjustment" do
    statement { create(:ecf_statement) }
    sequence(:payment_type) { |n| "Custom payment #{n}" }
    amount { 9.99 }
  end
end
