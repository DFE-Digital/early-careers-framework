# frozen_string_literal: true

RSpec.describe Archive::DestroyECFProfileData do
  let(:participant_profile) { create(:seed_ect_participant_profile, :valid) }
  let!(:induction_record) { create_list(:seed_induction_record, 2, :valid, participant_profile:) }
  let!(:user) { participant_profile.user }

  subject(:service_call) { described_class.call(participant_profile:) }

  it "removes the ParticipantProfile record" do
    expect { service_call }.to change { ParticipantProfile.count }.by(-1)
  end

  it "removes the induction records" do
    expect { service_call }.to change { InductionRecord.count }.by(-2)
  end

  it "does not remove the any ParticipantIdentity records" do
    # participant_profile
    expect { service_call }.not_to change { ParticipantIdentity.count }
  end

  it "does not remove the User" do
    # user
    expect { service_call }.not_to change { User.count }
  end

  context "when the profile has a declaration" do
    let(:state) { "submitted" }
    let!(:declaration) { create(:seed_ecf_participant_declaration, :with_cpd_lead_provider, state:, user:, participant_profile:) }

    it "destroys the declarations" do
      expect { service_call }.to change { ParticipantDeclaration.count }.by(-1)
    end
  end

  context "when the profile has an eligibility record" do
    let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

    it "destroys the eligibility record" do
      expect { service_call }.to change { ECFParticipantEligibility.count }.by(-1)
    end
  end

  context "when the profile has validation data" do
    let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

    it "destroys the validation data" do
      expect { service_call }.to change { ECFParticipantValidationData.count }.by(-1)
    end
  end

  context "when the profile is a mentor" do
    let(:participant_profile) { create(:seed_mentor_participant_profile, :valid) }
    let!(:school_mentor) { create(:seed_school_mentor, :with_school, preferred_identity: participant_profile.participant_identity, participant_profile:) }

    it "removes their school mentor relations" do
      expect {
        service_call
      }.to change { SchoolMentor.count }.by(-1)
    end

    context "when the profile has mentees" do
      let!(:mentee) { create(:seed_induction_record, :valid, mentor_profile: participant_profile) }

      it "raises an ArchiveError" do
        expect {
          service_call
        }.to raise_error Archive::ArchiveError
      end
    end
  end

  context "when the profile has schedule records" do
    let!(:schedule) { ParticipantProfileSchedule.create!(schedule: participant_profile.schedule, participant_profile:) }

    it "removes the participant profile schedules" do
      expect {
        service_call
      }.to change { ParticipantProfileSchedule.count }.by(-1)
    end
  end

  context "when the profile has states" do
    let!(:states) { create_list(:seed_ect_participant_profile_state, 3, participant_profile:) }

    it "removes the participant profile states" do
      expect {
        service_call
      }.to change { ParticipantProfileState.count }.by(-3)
    end
  end

  context "when the profile has validation decisions" do
    let!(:decision) do
      ProfileValidationDecision.create!(participant_profile_id: participant_profile.id, note: "yes", approved: true,
                                        validation_step: :something)
    end

    it "removes the profile validation decision" do
      expect {
        service_call
      }.to change { ProfileValidationDecision.count }.by(-1)
    end
  end

  context "when the profile has deleted duplicates" do
    before do
      Finance::ECF::DeletedDuplicate.create!(data: { some: "data" }.to_json, primary_participant_profile: participant_profile)
    end

    it "removes the deleted duplicates" do
      expect {
        service_call
      }.to change { Finance::ECF::DeletedDuplicate.count }.by(-1)
    end
  end
end
