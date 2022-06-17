# frozen_string_literal: true

FactoryBot.define do
  factory :statement, class: "Finance::Statement" do
    name          { Time.zone.today.strftime "%B %Y" }
    deadline_date { (Time.zone.today - 1.month).end_of_month }
    payment_date  { Time.zone.today.end_of_month }
    cohort        { Cohort.current || create(:cohort, :current) }
    contract_version { "1.0" }

    factory :npq_statement, class: "Finance::Statement::NPQ" do
      association :cpd_lead_provider, :with_npq_lead_provider

      trait :payable do
        type { "Finance::Statement::NPQ::Payable" }
      end
    end

    factory :ecf_statement, class: "Finance::Statement::ECF" do
      association :cpd_lead_provider, :with_lead_provider
    end

    trait :output_fee do
      output_fee { true }
    end
  end
end
