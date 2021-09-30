# frozen_string_literal: true

RSpec.describe Admin::Participants::TableRow, type: :view_component do
  let(:participant_profile) { create :participant_profile }
  let(:school) { participant_profile.school }

  component { described_class.new profile: participant_profile }

  it { is_expected.to have_link participant_profile.user.full_name, href: admin_participant_path(participant_profile) }
  it { is_expected.to have_content I18n.t(participant_profile.participant_type, scope: "schools.participants.type") }
  it { is_expected.to have_content participant_profile.created_at.to_date.to_s(:govuk_short) }

  context "when profile is associated with the school" do
    let(:school) { create :school }
    let(:participant_profile) { create :participant_profile, school: school }

    it { is_expected.to have_content school.name }
    it { is_expected.to have_content school.urn }
  end

  context "when profile is not associated with the school" do
    let(:participant_profile) { create :participant_profile, school: nil }

    it { is_expected.to have_css(".govuk-table__cell:nth-child(3)", text: "\n    School\n    \n") }
  end

  context "when profile is not associated with the school but has school_urn" do
    let(:participant_profile) { create :participant_profile, school: nil, school_urn: "123456" }

    it { is_expected.to have_content("123456") }
  end
end
