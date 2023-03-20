# frozen_string_literal: true

RSpec.describe AppropriateBodies::Participants::TableRow, type: :component do
  let(:school_cohort) { create(:school_cohort) }
  let(:induction_record) { create :induction_record, participant_profile: }

  let(:component) { described_class.new induction_record: }

  subject { render_inline(component) }

  context "when the participant profile is for a ECT" do
    let(:participant_profile) { create :ect_participant_profile, school_cohort: }

    it { is_expected.to have_text("Early career teacher") }
  end

  context "when the participant profile is for a Mentor" do
    let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }

    it { is_expected.to have_text("Mentor") }
  end

  context "when the participant profile is for a Mentor and Induction Tutor" do
    let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:induction_coordinator_profile) { create(:induction_coordinator_profile, user: participant_profile.user) }

    it { is_expected.to have_text("Mentor") }
  end
end
