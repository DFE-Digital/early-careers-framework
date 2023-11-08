# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::TableRow, type: :component do
  let(:partnership)   { create :partnership }
  let(:school)        { partnership.school }
  let(:cohort)        { partnership.cohort }
  let(:school_cohort) { create(:school_cohort, school:, cohort:) }

  let(:component) { described_class.new partnership: }
  subject { render_inline(component) }

  it { is_expected.to have_link school.name, href: lead_providers_partnership_path(partnership) }
  it { is_expected.to have_content school.urn }
  it { is_expected.to have_content partnership.delivery_partner.name }

  context "with ECT in given cohort" do
    let!(:ect_profiles) do
      create_list(:ect, rand(1..5), school_cohort:).tap do |participant_profiles|
        participant_profiles.each do |participant_profile|
          create(:induction_record, school_cohort:, participant_profile:, partnership:)
        end
      end
    end

    it { is_expected.to have_css "td.govuk-table__cell--numeric", text: ect_profiles.count }
  end
end
