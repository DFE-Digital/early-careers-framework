# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Adjustments, type: :component do
  let(:statement) { instance_double(Finance::Statement, adjustments: [], adjustment_editable?: false) }
  let(:component) { described_class.new(statement:, calculator:) }
  let(:output_calculator) { instance_double(Finance::ECF::OutputCalculator, banding_breakdown:) }
  let(:calculator) do
    instance_double(
      Finance::ECF::StatementCalculator,
      output_calculator:,
      uplift_additions_count: 99,
      uplift_fee_per_declaration: 333.0,
      uplift_deductions_count: 88,
      uplift_clawback_deductions: 55,
      adjustments_total: 2000,
      fee_for_declaration: 10,
    )
  end
  let(:banding_breakdown) do
    [
      {
        band: :a,
        min: 1,
        max: 2,
        started_subtractions: 1,
        completed_subtractions: 3,
      },
      {
        band: :b,
        min: 3,
        max: 4,
        started_subtractions: 5,
        completed_subtractions: 7,
      },
    ]
  end

  subject { render_inline(component) }

  before do
    component = instance_double(Finance::Statements::AdditionalAdjustments::Table, render_in: "<h2>Additional adjustments</h2>".html_safe)
    expect(Finance::Statements::AdditionalAdjustments::Table).to receive(:new).with(statement:).and_return(component)
  end

  it "renders additional adjustments component" do
    expect(subject).to have_css("h2", text: "Additional adjustments")
  end

  it "has correct heading" do
    expect(subject).to have_css("h2", text: "Adjustments")
    expect(subject).to have_css(".govuk-table > caption", text: "Clawbacks")

    expect(subject).to have_css(".govuk-table__head > .govuk-table__row", count: 1)

    is_expected.to have_table_heading("Payment type", col: 1)
    is_expected.to have_table_heading("Number of participants", col: 2)
    is_expected.to have_table_heading("Fee per participant", col: 3)
    is_expected.to have_table_heading("Payments", col: 4)
  end

  it "has correct table values" do
    expect(subject).to have_css(".govuk-table__body > .govuk-table__row", count: 5)

    is_expected.to have_table_value("Uplift clawbacks", row: 1, col: 1)
    is_expected.to have_table_value(88, row: 1, col: 2)
    is_expected.to have_table_value("-£333.00", row: 1, col: 3)
    is_expected.to have_table_value("£55.00", row: 1, col: 4)

    is_expected.to have_table_value("Clawback for Started (Band: A)", row: 2, col: 1)
    is_expected.to have_table_value(1, row: 2, col: 2)
    is_expected.to have_table_value("-£10.00", row: 2, col: 3)
    is_expected.to have_table_value("£10.00", row: 2, col: 4)

    is_expected.to have_table_value("Clawback for Completed (Band: A)", row: 3, col: 1)
    is_expected.to have_table_value(3, row: 3, col: 2)
    is_expected.to have_table_value("-£10.00", row: 3, col: 3)
    is_expected.to have_table_value("£30.00", row: 3, col: 4)

    is_expected.to have_table_value("Clawback for Started (Band: B)", row: 4, col: 1)
    is_expected.to have_table_value(5, row: 4, col: 2)
    is_expected.to have_table_value("-£10.00", row: 4, col: 3)
    is_expected.to have_table_value("£50.00", row: 4, col: 4)

    is_expected.to have_table_value("Clawback for Completed (Band: B)", row: 5, col: 1)
    is_expected.to have_table_value(7, row: 5, col: 2)
    is_expected.to have_table_value("-£10.00", row: 5, col: 3)
    is_expected.to have_table_value("£70.00", row: 5, col: 4)
  end

  it "has correct total" do
    expect(subject).to have_css("div.govuk-heading-s", text: "£2,000.00")
  end

  def have_table_heading(txt, col:)
    have_css(".govuk-table__head > .govuk-table__row:nth-child(1) > .govuk-table__header:nth-child(#{col})", text: txt)
  end

  def have_table_value(txt, row:, col:)
    have_css(".govuk-table__body > .govuk-table__row:nth-child(#{row}) > .govuk-table__cell:nth-child(#{col})", text: txt)
  end
end
