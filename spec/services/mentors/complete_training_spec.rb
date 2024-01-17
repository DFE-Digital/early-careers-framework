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
      expect(mentor_profile.mentor_completion_date).to eq Date.new(2021, 4, 19)
    end
  end

  context "when the mentor has a completed declaration" do
    let!(:declaration) { create(:seed_ecf_participant_declaration, :with_cpd_lead_provider, :completed, user: mentor_profile.user, participant_profile: mentor_profile) }

    it "sets the mentor_completion_date to the declaration date" do
      service_call
      expect(mentor_profile.mentor_completion_date.to_date).to eq declaration.declaration_date.to_date
    end
  end

  context "when the mentor has not completed training" do
    it "does not set the mentor_completion_date" do
      service_call
      expect(mentor_profile.mentor_completion_date).to be_nil
    end
  end
end
