# frozen_string_literal: true

RSpec.describe Finance::Statements::DeclarationsBreakdown::Section, type: :component do
  let(:lead_provider) { instance_double(LeadProvider, id: "0512d6f9-e082-471e-aad2-feb9f77ff870") }
  let(:cpd_lead_provider) { instance_double(CpdLeadProvider, lead_provider:) }
  let(:statement) { instance_double(Finance::Statement, cpd_lead_provider:) }
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
      extended_count: 0,
      clawed_back_count: 1,
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
      clawed_back_count: 2,
      voided_count: 51,
    )
  end
  let(:component) { described_class.new(statement:, ect_calculator:, mentor_calculator:) }

  subject { render_inline(component) }

  it "renders table component" do
    expect(subject).to have_css(".govuk-table > caption.govuk-table__caption--s", count: 0)
    expect(subject).to have_css(".govuk-table > caption.govuk-table__caption--m", count: 1)
    expect(subject).to have_css(".govuk-table > caption.govuk-table__caption--m", text: "Declarations Summary")
  end

  it "renders download csv link" do
    expect(subject)
    .to have_link("Download declarations (CSV)", href: finance_ecf_statement_assurance_report_path(statement, format: :csv))
  end
end
