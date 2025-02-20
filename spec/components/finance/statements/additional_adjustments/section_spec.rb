# frozen_string_literal: true

RSpec.describe Finance::Statements::AdditionalAdjustments::Section, type: :component do
  let(:statement) { instance_double(Finance::Statement, adjustments: [], adjustment_editable?: false) }
  let(:component) { described_class.new statement: }

  subject { render_inline(component) }

  it "renders table component" do
    expect(subject).to have_css(".govuk-table > caption.govuk-table__caption--s", count: 0)
    expect(subject).to have_css(".govuk-table > caption.govuk-table__caption--m", count: 1)
    expect(subject).to have_css(".govuk-table > caption.govuk-table__caption--m", text: "Additional adjustments")
  end
end
