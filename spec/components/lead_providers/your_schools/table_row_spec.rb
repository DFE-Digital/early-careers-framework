# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::TableRow, type: :component do
  let(:partnership) { create :partnership }
  let(:participant_counts) { {} }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }
  let(:school_cohort) { create(:school_cohort, school:, cohort:) }

  before { render_inline(described_class.new(partnership:, participant_counts:)) }

  it "renders a link to the school partnership" do
    expect(rendered_content).to have_link school.name, href: lead_providers_partnership_path(partnership)
  end

  it "displays the school URN" do
    expect(rendered_content).to have_content school.urn
  end

  it "displays the delivery partner name" do
    expect(rendered_content).to have_content partnership.delivery_partner.name
  end

  context "with ECTs for the partnership" do
    let(:participant_counts) { { partnership.id => { ect_count: 5, mentor_count: 2 } } }

    it "displays the ECT count" do
      expect(rendered_content).to have_css "td.govuk-table__cell--numeric", text: 5
    end

    it "displays the mentor count" do
      expect(rendered_content).to have_css "td.govuk-table__cell--numeric", text: 2
    end
  end
end
