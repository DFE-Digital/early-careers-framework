# frozen_string_literal: true

FactoryBot.define do
  factory :ecf_statement, class: "finance/statement/ecf" do
    name { "Statement of fact" }
    cpd_lead_provider
    deadline_date { 1.month.ago }
    payment_date { 2.days.from_now }
  end
end
