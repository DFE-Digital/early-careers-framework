# frozen_string_literal: true

RSpec.describe Archive::FrozenCohortProfile do
  let(:cohort) { Cohort.find_by(start_year: 2021) }
  let(:participant_profile) { create(:ect_participant_profile, cohort:) }
  let!(:user) { participant_profile.user }

  subject(:service_call) { described_class.call(participant_profile) }

  before do
    cohort.update!(payments_frozen_at: 1.day.ago)
  end

  it "creates a Relic record" do
    expect { service_call }.to change { Archive::Relic.count }.by(1)
  end

  it "removes the ParticipantProfile record" do
    participant_profile
    expect { service_call }.to change { ParticipantProfile.count }.by(-1)
  end

  it "does not remove the any ParticipantIdentity records" do
    participant_profile
    expect { service_call }.not_to change { ParticipantIdentity.count }
  end

  it "does not remove the User" do
    user
    expect { service_call }.not_to change { User.count }
  end

  describe "relic details" do
    let(:relic) { service_call }

    it "sets the reason on the Relic" do
      expect(relic.reason).to eq "undeclared participants in frozen cohort"
    end

    it "sets the object_type" do
      expect(relic.object_type).to eq participant_profile.class.name
    end

    it "sets the object_id" do
      expect(relic.object_id).to eq participant_profile.id
    end

    it "sets the display_name" do
      expect(relic.display_name).to eq user.full_name
    end

    it "sets the relic data to the serialized participant_profile record" do
      expect(relic.data.to_json).to eq Archive::ParticipantProfileSerializer.new(participant_profile).serializable_hash[:data].to_json
    end

    context "when a reason is specified" do
      let(:relic) { described_class.call(participant_profile, reason: "a different reason") }

      it "sets the reason correctly" do
        expect(relic.reason).to eq "a different reason"
      end
    end
  end

  context "when the participant is not in a frozen cohort" do
    let(:participant_profile) { create(:ect_participant_profile, cohort: Cohort.current) }

    it "raises an ArchiveError" do
      expect {
        described_class.call(participant_profile)
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the profile has a declaration" do
    let(:state) { "payable" }
    let!(:declaration) { create(:seed_ecf_participant_declaration, :with_cpd_lead_provider, state:, user:, participant_profile:) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end

    context "when the declaration is submitted, ineligible or void" do
      %w[submitted ineligible voided].each do |declaration_state|
        let(:state) { declaration_state }

        it "creates a Relic" do
          expect {
            service_call
          }.to change { Archive::Relic.count }.by(1)
        end

        it "does not raise an error" do
          expect {
            service_call
          }.not_to raise_error
        end
      end
    end
  end

  context "when the keep original flag is set" do
    let(:relic) { described_class.call(participant_profile, keep_original: true) }

    it "creates a Relic" do
      expect {
        relic
      }.to change { Archive::Relic.count }.by(1)
    end

    it "does not remove any of the source records" do
      participant_profile
      expect {
        relic
      }.not_to change { ParticipantProfile.count }
    end
  end

  context "when the profile has an eligibility record" do
    let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

    it "removes their eligibility record" do
      expect {
        service_call
      }.to change { ECFParticipantEligibility.count }.by(-1)
    end
  end

  context "when the profile is a mentor" do
    let(:participant_profile) { create(:mentor_participant_profile, cohort:) }
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

  context "when the profile has states" do
    let!(:states) { create_list(:seed_ect_participant_profile_state, 3, participant_profile:) }

    it "removes the participant profile states" do
      expect {
        service_call
      }.to change { ParticipantProfileState.count }.by(-3)
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
