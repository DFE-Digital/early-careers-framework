# frozen_string_literal: true

FactoryBot.define do
  factory :statement, class: "Finance::Statement" do
    name          { Time.zone.today.strftime "%B %Y" }
    deadline_date { (Time.zone.today - 1.month).end_of_month }
    payment_date  { Time.zone.today.end_of_month }

    factory :npq_statement, class: "Finance::Statement::NPQ" do
      association :cpd_lead_provider, :with_npq_lead_provider
    end
  end
end
