# frozen_string_literal: true

RSpec.describe AppropriateBodies::Participants::TableRow, type: :component do
  let(:participant_profile) { create :ect_participant_profile, training_status: "withdrawn" }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:, training_status: "withdrawn") }
  let(:training_record_states) { DetermineTrainingRecordState.call(participant_profiles: participant_profile, induction_records: induction_record) }

  let(:component) { described_class.new induction_record:, training_record_states: }

  subject { render_inline(component) }

  context "FIP induction type" do
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }

    it { is_expected.to have_text(participant_profile.user.full_name) }
    it { is_expected.to have_text(participant_profile.teacher_profile.trn) }
    it { is_expected.to have_text(induction_record.school.urn) }
    it { is_expected.to have_text("ECT not currently linked to you") }
    it { is_expected.to have_text("FIP") }
    it { is_expected.to have_text(induction_record.school.contact_email) }
  end

  context "CIP induction type" do
    let(:induction_programme) { create(:induction_programme, :cip, school_cohort:) }

    it { is_expected.to have_text(participant_profile.user.full_name) }
    it { is_expected.to have_text(participant_profile.teacher_profile.trn) }
    it { is_expected.to have_text(induction_record.school.urn) }
    it { is_expected.to have_text("ECT not currently linked to you") }
    it { is_expected.to have_text("CIP") }
    it { is_expected.to have_text(induction_record.school.contact_email) }
  end
end
