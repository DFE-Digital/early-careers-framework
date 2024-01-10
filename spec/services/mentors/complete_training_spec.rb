# frozen_string_literal: true

RSpec.describe Mentors::CompleteTraining do
  let(:trn) { "0120123" }
  let(:teacher_profile) { create(:seed_teacher_profile, :valid, trn:) }
  let(:mentor_profile) { create(:seed_mentor_participant_profile, :with_schedule, :with_participant_identity, :with_school_cohort, teacher_profile:) }

  let(:service_call) { described_class.call(mentor_profile:) }

  context "when the mentor undertook training in the ERO phase" do
    let!(:ineligible_record) { create(:seed_ecf_ineligible_participant, trn:) }

    it "sets the mentor_completion_date to 19/4/2021" do
      service_call
      expect(mentor_profile.reload.mentor_completion_date).to eq Date.new(2021, 4, 19)
    end
  end

  context "when the mentor has a completed declaration" do
  end

  context "when the mentor has not completed training" do
  end

  context "when a mentor profile is not supplied" do
  end
end
