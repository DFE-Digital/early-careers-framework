# frozen_string_literal: true

FactoryBot.define do
  factory :npq_statement, class: "finance/statement/npq" do
    sequence(:name) { |n| "NPQ statement #{n}" }
    association :cpd_lead_provider, :with_npq_lead_provider
    deadline_date { 1.month.ago }
    payment_date { 2.days.from_now }
  end
end
