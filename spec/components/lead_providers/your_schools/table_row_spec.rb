# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::TableRow, type: :component do
  let(:partnership) { create :partnership }
  let(:profiles_by_partnership) { {} }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }
  let(:school_cohort) { create(:school_cohort, school:, cohort:) }

  let(:component) { described_class.new partnership:, profiles_by_partnership: }
  subject { render_inline(component) }

  it { is_expected.to have_link school.name, href: lead_providers_partnership_path(partnership) }
  it { is_expected.to have_content school.urn }
  it { is_expected.to have_content partnership.delivery_partner.name }

  context "with ECTs for the partnership" do
    let(:profiles_by_partnership) { { [partnership.id, "ParticipantProfile::ECT"] => 5 } }

    it { is_expected.to have_css "td.govuk-table__cell--numeric", text: 5 }
    it { is_expected.to have_css "td.govuk-table__cell--numeric", text: 0 }
  end
end
