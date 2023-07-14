# frozen_string_literal: true

RSpec.describe Finance::AdditionalAdjustments::Table, type: :component do
  let(:statement) { create :ecf_statement }
  let(:component) { described_class.new statement: }

  subject { render_inline(component) }

  context "no adjustments" do
    it "renders correctly" do
      expect(statement.adjustments.count).to eql(0)
      is_expected.to have_table_row_count(1)
      is_expected.to have_table_text("", row: 1, col: 1)
      is_expected.to have_table_text("£0.00", row: 1, col: 2)
    end
  end

  context "one adjustment" do
    let!(:adjustment) { create :adjustment, statement:, payment_type: "Big amount", amount: 999.99 }

    it "renders correctly" do
      expect(statement.adjustments.count).to eql(1)
      is_expected.to have_table_row_count(1)
      is_expected.to have_table_text("Big amount", row: 1, col: 1)
      is_expected.to have_table_text("£999.99", row: 1, col: 2)
      expect(component.total_amount).to eql(999.99)
    end
  end

  context "multiple adjustments" do
    let!(:adjustment1) { create :adjustment, statement:, payment_type: "Big amount", amount: 999.99 }
    let!(:adjustment2) { create :adjustment, statement:, payment_type: "Negative amount", amount: -500.0 }
    let!(:adjustment3) { create :adjustment, statement:, payment_type: "Another amount", amount: 300.0 }

    it "renders correctly" do
      expect(statement.adjustments.count).to eql(3)
      is_expected.to have_table_row_count(3)

      is_expected.to have_table_text("Big amount", row: 1, col: 1)
      is_expected.to have_table_text("£999.99", row: 1, col: 2)

      is_expected.to have_table_text("Negative amount", row: 2, col: 1)
      is_expected.to have_table_text("-£500.00", row: 2, col: 2)

      is_expected.to have_table_text("Another amount", row: 3, col: 1)
      is_expected.to have_table_text("£300.00", row: 3, col: 2)

      expect(component.total_amount.to_s).to eql("799.99")
    end
  end

  def have_table_text(txt, row:, col:)
    have_css(".govuk-table__body > .govuk-table__row:nth-child(#{row}) > .govuk-table__cell:nth-child(#{col})", text: txt)
  end

  def have_table_row_count(count)
    have_css(".govuk-table__body > .govuk-table__row", count:)
  end
end
