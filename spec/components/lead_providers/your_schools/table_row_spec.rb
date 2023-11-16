# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::TableRow, type: :component do
  let(:partnership) { create :partnership }
  let(:participant_counts) { {} }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }
  let(:school_cohort) { create(:school_cohort, school:, cohort:) }

  let(:component) { described_class.new partnership:, participant_counts: }
  subject { render_inline(component) }

  it { is_expected.to have_link school.name, href: lead_providers_partnership_path(partnership) }
  it { is_expected.to have_content school.urn }
  it { is_expected.to have_content partnership.delivery_partner.name }

  context "with ECTs for the partnership" do
    let(:participant_counts) { { partnership.id => { ect_count: 5, mentor_count: 2 } } }

    it { is_expected.to have_css "td.govuk-table__cell--numeric", text: 5 }
    it { is_expected.to have_css "td.govuk-table__cell--numeric", text: 2 }
  end
end
