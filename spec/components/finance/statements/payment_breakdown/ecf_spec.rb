# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::PaymentBreakdown::ECF, type: :component do
  let(:lead_provider) { instance_double(LeadProvider, id: "0512d6f9-e082-471e-aad2-feb9f77ff870") }
  let(:cpd_lead_provider) { instance_double(CpdLeadProvider, lead_provider:) }
  let(:statement) { instance_double(Finance::Statement, cpd_lead_provider:, deadline_date: Time.zone.today, payment_date: Time.zone.tomorrow) }
  let(:component) { described_class.new(statement:, calculator:) }
  let(:calculator) do
    instance_double(
      Finance::ECF::StatementCalculator,
      total: 1000,
      output_fee: 100,
      service_fee: 200,
      total_for_uplift: 300,
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
  let(:extended_count) { 0 }

  subject { render_inline(component) }

  it "has correct breakdown" do
    expect(subject).to have_css("h4", text: "Total £1,000.00")

    expect(breakdown_list[0][0]).to eq("Output payment")
    expect(breakdown_list[0][1]).to eq("£100.00")

    expect(breakdown_list[1][0]).to eq("Service fee")
    expect(breakdown_list[1][1]).to eq("£200.00")

    expect(breakdown_list[2][0]).to eq("Uplift fees")
    expect(breakdown_list[2][1]).to eq("£300.00")

    expect(breakdown_list[3][0]).to eq("Clawbacks")
    expect(breakdown_list[3][1]).to eq("£400.00")

    expect(breakdown_list[4][0]).to eq("Additional adjustments")
    expect(breakdown_list[4][1]).to eq("£500.00")

    expect(breakdown_list[5][0]).to eq("VAT")
    expect(breakdown_list[5][1]).to eq("£600.00")
  end

  it "has correct dates" do
    expect(subject).to have_css(".finance-panel__summary__meta__dates div:nth-child(1) div:nth-child(1) strong", text: "Milestone cut off date")
    expect(subject).to have_css(".finance-panel__summary__meta__dates div:nth-child(1) div:nth-child(2)", text: statement.deadline_date.to_fs(:govuk))

    expect(subject).to have_css(".finance-panel__summary__meta__dates div:nth-child(2) div:nth-child(1) strong", text: "Payment date")
    expect(subject).to have_css(".finance-panel__summary__meta__dates div:nth-child(2) div:nth-child(2)", text: statement.payment_date.to_fs(:govuk))
  end

  it "has correct declaration counts" do
    expect(counts_list[0][0]).to eq("Total starts")
    expect(counts_list[0][1]).to eq("10")

    expect(counts_list[1][0]).to eq("Total retained")
    expect(counts_list[1][1]).to eq("20")

    expect(counts_list[2][0]).to eq("Total completed")
    expect(counts_list[2][1]).to eq("30")

    expect(counts_list[3][0]).to eq("Total voided")
    expect(counts_list[3][1]).to eq("50")
  end

  describe "with extended count" do
    let(:extended_count) { 40 }

    it "has correct declaration counts" do
      expect(counts_list[0][0]).to eq("Total starts")
      expect(counts_list[0][1]).to eq("10")

      expect(counts_list[1][0]).to eq("Total retained")
      expect(counts_list[1][1]).to eq("20")

      expect(counts_list[2][0]).to eq("Total completed")
      expect(counts_list[2][1]).to eq("30")

      expect(counts_list[3][0]).to eq("Total extended")
      expect(counts_list[3][1]).to eq("40")

      expect(counts_list[4][0]).to eq("Total voided")
      expect(counts_list[4][1]).to eq("50")
    end
  end

  it "has link to voided declarations" do
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
      subject.css(".finance-panel__summary__meta__counts div").map { |row|
        key = row.css("strong").text.strip
        next if key.blank?

        val = row.css("div").text.strip
        [key, val]
      }.compact
  end
end
