# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::PaymentBreakdown::ECTMentor, type: :component do
  let(:lead_provider) { instance_double(LeadProvider, id: "0512d6f9-e082-471e-aad2-feb9f77ff870") }
  let(:cpd_lead_provider) { instance_double(CpdLeadProvider, lead_provider:) }
  let(:statement) { instance_double(Finance::Statement, cpd_lead_provider:, deadline_date: Time.zone.today, payment_date: Time.zone.tomorrow) }
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

  subject { render_inline(component) }

  it "has correct breakdown" do
    expect(subject).to have_css("h4", text: "Total £2,100.00")

    expect(breakdown_list[0][0]).to eq("ECTs output payment")
    expect(breakdown_list[0][1]).to eq("£100.00")

    expect(breakdown_list[1][0]).to eq("Mentors output payment")
    expect(breakdown_list[1][1]).to eq("£110.00")

    expect(breakdown_list[2][0]).to eq("Service fee")
    expect(breakdown_list[2][1]).to eq("£200.00")

    expect(breakdown_list[3][0]).to eq("ECT clawbacks")
    expect(breakdown_list[3][1]).to eq("£400.00")

    expect(breakdown_list[4][0]).to eq("Mentor clawbacks")
    expect(breakdown_list[4][1]).to eq("£410.00")

    expect(breakdown_list[5][0]).to eq("Additional adjustments")
    expect(breakdown_list[5][1]).to eq("£500.00")

    expect(breakdown_list[6][0]).to eq("VAT")
    expect(breakdown_list[6][1]).to eq("£1,210.00")
  end

  it "has correct dates" do
    expect(subject).to have_css(".finance-panel__dates div:nth-child(1) div:nth-child(1) strong", text: "Milestone cut off date")
    expect(subject).to have_css(".finance-panel__dates div:nth-child(1) div:nth-child(2)", text: statement.deadline_date.to_fs(:govuk))

    expect(subject).to have_css(".finance-panel__dates div:nth-child(2) div:nth-child(1) strong", text: "Payment date")
    expect(subject).to have_css(".finance-panel__dates div:nth-child(2) div:nth-child(2)", text: statement.payment_date.to_fs(:govuk))
  end

  it "has correct declaration counts" do
    expect(counts_list[0][1]).to eq("Started")
    expect(counts_list[0][2]).to eq("Retained")
    expect(counts_list[0][3]).to eq("Completed")
    expect(counts_list[0][4]).to eq("Voided")

    expect(counts_list[1][0]).to eq("ECTs")
    expect(counts_list[1][1]).to eq("10")
    expect(counts_list[1][2]).to eq("20")
    expect(counts_list[1][3]).to eq("30")
    expect(counts_list[1][4]).to eq("50")

    expect(counts_list[2][0]).to eq("Mentors")
    expect(counts_list[2][1]).to eq("11")
    expect(counts_list[2][2]).to eq("-")
    expect(counts_list[2][3]).to eq("31")
    expect(counts_list[2][4]).to eq("51")
  end

  describe "with extended count" do
    let(:extended_count) { 40 }

    it "has correct declaration counts" do
      expect(counts_list[0][1]).to eq("Started")
      expect(counts_list[0][2]).to eq("Retained")
      expect(counts_list[0][3]).to eq("Completed")
      expect(counts_list[0][4]).to eq("Extended")
      expect(counts_list[0][5]).to eq("Voided")

      expect(counts_list[1][0]).to eq("ECTs")
      expect(counts_list[1][1]).to eq("10")
      expect(counts_list[1][2]).to eq("20")
      expect(counts_list[1][3]).to eq("30")
      expect(counts_list[1][4]).to eq("40")
      expect(counts_list[1][5]).to eq("50")

      expect(counts_list[2][0]).to eq("Mentors")
      expect(counts_list[2][1]).to eq("11")
      expect(counts_list[2][2]).to eq("-")
      expect(counts_list[2][3]).to eq("31")
      expect(counts_list[2][4]).to eq("-")
      expect(counts_list[2][5]).to eq("51")
    end
  end

  xit "has link to voided declarations" do
    within(".finance-panel__summary__meta__counts") do
      expect(subject).to have_link("View", href: finance_ecf_payment_breakdown_statement_voided_path(ecf_lead_provider.id, statement))
    end
  end

  def breakdown_list
    @breakdown_list ||=
      subject.css(".finance-panel__summary__total-payment-breakdown p").map do |row|
        val = row.css("span").text.strip
        key = row.text.gsub(val, "").strip
        [key, val]
      end
  end

  def counts_list
    @counts_list ||=
      subject.css(".finance-panel__summary__counts .govuk-table tr").map do |row|
        row.css("th, td").map { |v| v.text.strip.to_s.split.first }
      end
  end
end
