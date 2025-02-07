# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::OutputPayments, type: :component do
  let(:component) { described_class.new(calculator:) }
  let(:calculator) do
    instance_double(
      Finance::ECF::StatementCalculator,
      band_letters:,
      event_types_for_display:,
      output_fee: 10_000,

      started_band_a_additions: 1,
      started_band_a_fee_per_declaration: 10.0,

      started_band_b_additions: 2,
      started_band_b_fee_per_declaration: 20.0,

      completed_band_a_additions: 3,
      completed_band_a_fee_per_declaration: 30.0,

      completed_band_b_additions: 4,
      completed_band_b_fee_per_declaration: 40.0,

      additions_for_started: 3,
      additions_for_completed: 7,
    )
  end
  let(:band_letters) { %i[a b] }
  let(:event_types_for_display) { %i[started completed] }

  subject { render_inline(component) }

  it "has correct heading" do
    expect(subject).to have_css(".govuk-table > caption", text: "Output payments")
    expect(subject).to have_css(".govuk-table__head > .govuk-table__row", count: 1)

    is_expected.to have_table_heading("Outputs", col: 1)
    is_expected.to have_table_heading("Band A", col: 2)
    is_expected.to have_table_heading("Band B", col: 3)
    is_expected.to have_table_heading("Payments", col: 4)
  end

  it "has correct table values" do
    expect(subject).to have_css(".govuk-table__body > .govuk-table__row", count: 4)

    is_expected.to have_table_value_heading("Starts", row: 1, col: 1)
    is_expected.to have_table_value(1, row: 1, col: 2)
    is_expected.to have_table_value(2, row: 1, col: 3)

    is_expected.to have_table_value("Fee per participant", row: 2, col: 1)
    is_expected.to have_table_value("£10.00", row: 2, col: 2)
    is_expected.to have_table_value("£20.00", row: 2, col: 3)
    is_expected.to have_table_value("£3.00", row: 2, col: 4)

    is_expected.to have_table_value_heading("Completed", row: 3, col: 1)
    is_expected.to have_table_value(3, row: 3, col: 2)
    is_expected.to have_table_value(4, row: 3, col: 3)

    is_expected.to have_table_value("Fee per participant", row: 4, col: 1)
    is_expected.to have_table_value("£30.00", row: 4, col: 2)
    is_expected.to have_table_value("£40.00", row: 4, col: 3)
    is_expected.to have_table_value("£7.00", row: 4, col: 4)
  end

  it "has correct total" do
    expect(subject).to have_css("div.govuk-heading-s", text: "£10,000.00")
  end

  def have_table_heading(txt, col:)
    have_css(".govuk-table__head > .govuk-table__row:nth-child(1) > .govuk-table__header:nth-child(#{col})", text: txt)
  end

  def have_table_value(txt, row:, col:)
    have_css(".govuk-table__body > .govuk-table__row:nth-child(#{row}) > .govuk-table__cell:nth-child(#{col})", text: txt)
  end

  def have_table_value_heading(txt, row:, col:)
    have_css(".govuk-table__body > .govuk-table__row:nth-child(#{row}) > .govuk-table__header:nth-child(#{col})", text: txt)
  end
end
