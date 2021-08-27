# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::TableRow, type: :view_component do
  let(:partnership) { create :partnership }
  let(:school) { partnership.school }
  let(:cohort) { partnership.cohort }
  let(:school_cohort) { create(:school_cohort, school: school, cohort: cohort) }

  component { described_class.new partnership: partnership }

  it { is_expected.to have_link school.name, href: lead_providers_partnership_path(partnership) }
  it { is_expected.to have_content school.urn }
  it { is_expected.to have_content partnership.delivery_partner.name }

  context "with ECT in given cohort" do
    let!(:ect_profiles) { create_list :participant_profile, rand(1..5), :ect, school_cohort: school_cohort }

    it { is_expected.to have_css "td.govuk-table__cell--numeric", text: ect_profiles.count }
  end
end
