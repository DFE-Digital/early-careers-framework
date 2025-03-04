# frozen_string_literal: true

RSpec.describe Finance::Statements::DeclarationsBreakdown::ECTMentor, type: :component do
  let(:lead_provider) { instance_double(LeadProvider, id: "0512d6f9-e082-471e-aad2-feb9f77ff870") }
  let(:cpd_lead_provider) { instance_double(CpdLeadProvider, lead_provider:) }
  let(:statement) { instance_double(Finance::Statement, cpd_lead_provider:) }
  let(:ect_calculator) do
    instance_double(
      Finance::ECF::ECT::StatementCalculator,
      started_count: 10,
      retained_count: 20,
      completed_count: 30,
      extended_count: 0,
      clawed_back_count: 1,
      voided_count: 50,
    )
  end
  let(:mentor_calculator) do
    instance_double(
      Finance::ECF::Mentor::StatementCalculator,
      started_count: 11,
      completed_count: 31,
      clawed_back_count: 2,
      voided_count: 51,
    )
  end
  let(:component) { described_class.new(statement:, ect_calculator:, mentor_calculator:) }

  subject { render_inline(component) }

  it "renders correctly" do
    is_expected.to have_table_row_count(6)

    is_expected.to have_table_text("Started", row: 1, col: 1)
    is_expected.to have_table_text(10, row: 1, col: 2)
    is_expected.to have_table_text(11, row: 1, col: 3)

    is_expected.to have_table_text("Retained", row: 2, col: 1)
    is_expected.to have_table_text(20, row: 2, col: 2)
    is_expected.to have_table_text("-", row: 2, col: 3)

    is_expected.to have_table_text("Completed", row: 3, col: 1)
    is_expected.to have_table_text(30, row: 3, col: 2)
    is_expected.to have_table_text(31, row: 3, col: 3)

    is_expected.to have_table_text("Extended", row: 4, col: 1)
    is_expected.to have_table_text(0, row: 4, col: 2)
    is_expected.to have_table_text("-", row: 4, col: 3)

    is_expected.to have_table_text("Clawed back", row: 5, col: 1)
    is_expected.to have_table_text(1, row: 5, col: 2)
    is_expected.to have_table_text(2, row: 5, col: 3)

    is_expected.to have_table_text("Voided", row: 6, col: 1)
    is_expected.to have_table_text(50, row: 6, col: 2)
    is_expected.to have_table_text(51, row: 6, col: 3)

    is_expected
      .to have_link(50, href: ect_finance_ecf_payment_breakdown_statement_voided_path(lead_provider.id, statement))

    is_expected
      .to have_link(51, href: mentor_finance_ecf_payment_breakdown_statement_voided_path(lead_provider.id, statement))

    is_expected
      .to have_link("Download declarations (CSV)", href: finance_ecf_statement_assurance_report_path(statement, format: :csv))
  end

  def have_table_text(txt, row:, col:)
    have_css(".govuk-table__body > .govuk-table__row:nth-child(#{row}) > .govuk-table__cell:nth-child(#{col})", text: txt)
  end

  def have_table_row_count(count)
    have_css(".govuk-table__body > .govuk-table__row", count:)
  end
end
