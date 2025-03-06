# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::PaymentBreakdown::ECTMentor, type: :component do
  let(:lead_provider) { instance_double(LeadProvider, id: "0512d6f9-e082-471e-aad2-feb9f77ff870") }
  let(:cpd_lead_provider) { instance_double(CpdLeadProvider, lead_provider:) }
  let(:statement) { instance_double(Finance::Statement, cpd_lead_provider:, deadline_date: Time.zone.today, payment_date: Time.zone.tomorrow, to_param: "08a67c3d-ebc6-4a21-a446-923796a4e15c") }
  let(:component) { described_class.new(statement:, ect_calculator:, mentor_calculator:) }
  let(:ect_calculator) do
    instance_double(
      Finance::ECF::ECT::StatementCalculator,
      total: 1000,
      output_fee: 100,
      service_fee: 200,
      adjustments_total: 400,
      additional_adjustments_total: 500,
      vat: 600,
      started_count: 10,
      retained_count: 20,
      completed_count: 30,
      extended_count:,
      voided_count: 50,
    )
  end
  let(:mentor_calculator) do
    instance_double(
      Finance::ECF::Mentor::StatementCalculator,
      total: 1100,
      output_fee: 110,
      adjustments_total: 410,
      vat: 610,
      started_count: 11,
      completed_count: 31,
      voided_count: 51,
    )
  end
  let(:extended_count) { 0 }

  let(:breakdown_list) do
    subject.css(".finance-panel__summary__total-payment-breakdown .govuk-table").map { |row|
      row.css("caption", "th, td").map { |v| v.text.strip.to_s }.reject(&:empty?)
    }.flatten
  end

  subject { render_inline(component) }

  it "has correct breakdown" do
    expect(breakdown_list[0]).to eq("Total £2,100.00")

    expect(breakdown_list[1]).to eq("ECTs output payment")
    expect(breakdown_list[2]).to eq("£100.00")

    expect(breakdown_list[3]).to eq("Mentors output payment")
    expect(breakdown_list[4]).to eq("£110.00")

    expect(breakdown_list[5]).to eq("Service fee")
    expect(breakdown_list[6]).to eq("£200.00")

    expect(breakdown_list[7]).to eq("ECT clawbacks")
    expect(breakdown_list[8]).to eq("£400.00")

    expect(breakdown_list[9]).to eq("Mentor clawbacks")
    expect(breakdown_list[10]).to eq("£410.00")

    expect(breakdown_list[11]).to eq("Additional adjustments")
    expect(breakdown_list[12]).to eq("£500.00")

    expect(breakdown_list[13]).to eq("VAT")
    expect(breakdown_list[14]).to eq("£1,210.00")
  end

  it "has correct dates" do
    expect(subject).to have_css(".finance-panel__dates div:nth-child(1) div:nth-child(1) strong", text: "Milestone cut off date")
    expect(subject).to have_css(".finance-panel__dates div:nth-child(1) div:nth-child(2)", text: statement.deadline_date.to_fs(:govuk))

    expect(subject).to have_css(".finance-panel__dates div:nth-child(2) div:nth-child(1) strong", text: "Payment date")
    expect(subject).to have_css(".finance-panel__dates div:nth-child(2) div:nth-child(2)", text: statement.payment_date.to_fs(:govuk))
  end
end
