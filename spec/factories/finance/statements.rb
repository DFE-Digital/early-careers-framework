# frozen_string_literal: true

FactoryBot.define do
  factory :statement, class: "Finance::Statement" do
    name          { Time.zone.today.strftime "%B %Y" }
    deadline_date { (Time.zone.today - 1.month).end_of_month }
    payment_date  { Time.zone.today.end_of_month }
    cohort        { Cohort.current || create(:cohort, :current) }
    contract_version { "1.0" }

    factory :ecf_statement, class: "Finance::Statement::ECF" do
      cpd_lead_provider { association :cpd_lead_provider, :with_lead_provider }

      factory :ecf_paid_statement, class: "Finance::Statement::ECF::Paid" do
        paid
        marked_as_paid_at { Time.zone.now }
      end

      factory :ecf_payable_statement, class: "Finance::Statement::ECF::Payable" do
        payable
      end
    end

    trait :output_fee do
      output_fee { true }
    end

    trait :next_output_fee do
      output_fee
      deadline_date { Time.zone.today.end_of_month }
    end

    trait :payable do
      output_fee
      deadline_date { Time.zone.today - 1.day }
      payment_date { Time.zone.today - 1.day + 1.month }
    end

    trait :paid do
      output_fee
      deadline_date { Time.zone.today + 1.day + 1.month }
      payment_date { Time.zone.today + 1.day  }
    end
  end
end
