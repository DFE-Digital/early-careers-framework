# frozen_string_literal: true

RSpec.describe Admin::RecordsAnalysis::ECFParticipantTableRow, type: :component do
  let(:participant_profile) { create :ect_participant_profile }
  let(:school) { participant_profile.school }

  let(:component) { described_class.new profile: participant_profile }
  subject { render_inline(component) }

  it { is_expected.to have_link participant_profile.user.full_name, href: admin_participant_path(participant_profile) }
  it { is_expected.to have_content I18n.t(participant_profile.participant_type, scope: "schools.participants.type") }
  it { is_expected.to have_content participant_profile.created_at.to_date.to_s(:govuk_short) }

  context "when profile is associated with the school" do
    let(:school) { create :school }
    let(:participant_profile) { create :ect_participant_profile, school: }

    it { is_expected.to have_content school.name }
    it { is_expected.to have_content school.urn }

    context "when the profile has induction records" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:school_2) { school_cohort.school }
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
      let!(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }

      it { is_expected.to have_content school_2.name }
      it { is_expected.to have_content school_2.urn }
    end
  end
end
