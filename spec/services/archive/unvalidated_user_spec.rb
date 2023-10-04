# frozen_string_literal: true

RSpec.describe Archive::UnvalidatedUser do
  let(:participant_profile) { create(:ect_participant_profile) }
  let!(:user) { participant_profile.user }

  subject(:service_call) { described_class.call(user) }

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
      expect(relic.reason).to eq "unvalidated/undeclared ECTs 2021 or 2022"
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
      expect(relic.data.to_json).to eq Archive::UserSerializer.new(user).serializable_hash.to_json
    end

    context "when a reason is specified" do
      let(:relic) { described_class.call(user, reason: "a different reason") }

      it "sets the reason correctly" do
        expect(relic.reason).to eq "a different reason"
      end
    end
  end

  context "when the user has a declaration" do
    let(:state) { "submitted" }
    let!(:declaration) { create(:seed_ecf_participant_declaration, :with_cpd_lead_provider, state:, user:, participant_profile:) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end

    context "when the declaration is void" do
      let(:state) { "voided" }

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

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
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

  context "when the user has mentees" do
    let(:participant_profile) { create(:mentor_participant_profile) }
    let!(:mentee) { create(:seed_induction_record, :valid, mentor_profile: participant_profile) }

    it "raises an ArchiveError" do
      expect {
        service_call
      }.to raise_error Archive::ArchiveError
    end
  end
end
