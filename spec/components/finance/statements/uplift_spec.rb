# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Statements::Uplift, type: :component do
  let(:calculator) { instance_double(Finance::ECF::StatementCalculator, uplift_additions_count: 99, uplift_fee_per_declaration: 333.0) }
  let(:component) { described_class.new(calculator:) }

  subject { render_inline(component) }

  it "has correct heading" do
    expect(subject).to have_css(".govuk-table > caption", text: "Uplift fees")
    expect(subject).to have_css(".govuk-table__head > .govuk-table__row", count: 1)

    is_expected.to have_table_heading("Number of participants", col: 1)
    is_expected.to have_table_heading("Fee per participant", col: 2)
    is_expected.to have_table_heading("Payments", col: 3)
  end

  it "has correct table values" do
    expect(subject).to have_css(".govuk-table__body > .govuk-table__row", count: 1)

    is_expected.to have_table_value(99, row: 1, col: 1)
    is_expected.to have_table_value("£333.00", row: 1, col: 2)
    is_expected.to have_table_value("£32,967.00", row: 1, col: 3)
  end

  def have_table_heading(txt, col:)
    have_css(".govuk-table__head > .govuk-table__row:nth-child(1) > .govuk-table__header:nth-child(#{col})", text: txt)
  end

  def have_table_value(txt, row:, col:)
    have_css(".govuk-table__body > .govuk-table__row:nth-child(#{row}) > .govuk-table__cell:nth-child(#{col})", text: txt)
  end
end
