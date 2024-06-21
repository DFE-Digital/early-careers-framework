# frozen_string_literal: true

RSpec.describe Archive::UndeclaredUser do
  let(:cohort) { Cohort.find_by(start_year: 2021) }
  let(:participant_profile) { create(:ect_participant_profile, cohort:) }
  let!(:user) { participant_profile.user }

  subject(:service_call) { described_class.call(user, cohort_year: cohort.start_year) }

  it "creates a Relic record" do
    expect { service_call }.to change { Archive::Relic.count }.by(1)
  end

  it "removes the User record" do
    user
    expect { service_call }.to change { User.count }.by(-1)
  end

  describe "relic details" do
    let(:relic) { service_call }

    it "sets the reason on the Relic" do
      expect(relic.reason).to eq "undeclared participants in 2021"
    end

    it "sets the object_type" do
      expect(relic.object_type).to eq user.class.name
    end

    it "sets the object_id" do
      expect(relic.object_id).to eq user.id
    end

    it "sets the display_name" do
      expect(relic.display_name).to eq user.full_name
    end

    it "sets the relic data to the serialized user records" do
      expect(relic.data.to_json).to eq Archive::UserSerializer.new(user).serializable_hash[:data].to_json
    end

    context "when a reason is specified" do
      let(:relic) { described_class.call(user, reason: "a different reason") }

      it "sets the reason correctly" do
        expect(relic.reason).to eq "a different reason"
      end
    end
  end

  context "when the user has a declaration" do
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

    context "when the declaration has a different profile but same user (bad data)" do
      let(:profile2) { create(:ect_participant_profile) }
      let!(:declaration) { create(:seed_ecf_participant_declaration, :with_cpd_lead_provider, participant_profile: profile2, state:, user:) }

      it "raises an ArchiveError" do
        expect {
          service_call
        }.to raise_error Archive::ArchiveError
      end

      context "when the declaration is void" do
        let(:state) { "voided" }

        it "raises an ArchiveError" do
          expect {
            service_call
          }.to raise_error Archive::ArchiveError
        end
      end
    end
  end

  context "when the user has profiles in other cohorts" do
    let!(:profile2) { create(:mentor_participant_profile, cohort: Cohort.current, teacher_profile: participant_profile.teacher_profile) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the keep original flag is set" do
    let(:relic) { described_class.call(user, keep_original: true) }

    it "creates a Relic" do
      expect {
        relic
      }.to change { Archive::Relic.count }.by(1)
    end

    it "does not remove any or the source records" do
      user
      expect {
        relic
      }.to change { User.count }.by(0)
    end
  end

  context "when the user has an eligibility record" do
    let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

    it "removes the eligibility record" do
      expect {
        service_call
      }.to change { ECFParticipantEligibility.count }.by(-1)
    end
  end

  context "when the user has an admin profile" do
    let!(:admin_profile) { create(:admin_profile, user:) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the user has a finance profile" do
    let!(:finance_profile) { create(:finance_profile, user:) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the user has an appropriate_body profile" do
    let!(:appropriate_body_profile) { create(:appropriate_body_profile, user:) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the user has a lead_provider profile" do
    let!(:lead_provider_profile) { create(:lead_provider_profile, user:) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the user is a mentor" do
    let(:participant_profile) { create(:mentor_participant_profile, cohort:) }
    let!(:school_mentor) { create(:seed_school_mentor, :with_school, preferred_identity: participant_profile.participant_identity, participant_profile:) }

    it "removes their school mentor relations" do
      expect {
        service_call
      }.to change { SchoolMentor.count }.by(-1)
    end

    context "when the user has mentees" do
      let!(:mentee) { create(:seed_induction_record, :valid, mentor_profile: participant_profile) }

      it "raises an ArchiveError" do
        expect {
          service_call
        }.to raise_error Archive::ArchiveError
      end
    end
  end

  context "when the user has states" do
    let!(:states) { create_list(:seed_ect_participant_profile_state, 3, participant_profile:) }

    it "removes the participant profile states" do
      expect {
        service_call
      }.to change { ParticipantProfileState.count }.by(-3)
    end
  end

  context "when the user has a participant ID change record" do
    before do
      user.participant_id_changes.create!(from_participant: user, to_participant: create(:seed_user, :valid))
    end

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the user has a GAI ID" do
    before do
      user.update!(get_an_identity_id: SecureRandom.uuid)
    end

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end

  context "when the user is a mentor user on a participants declaration" do
    let(:participant_profile) { create(:mentor_participant_profile) }
    let!(:declaration) { create(:seed_ecf_participant_declaration, :valid, mentor_user_id: user.id) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end
end
