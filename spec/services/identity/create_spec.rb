# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Create do
  subject(:service) { described_class }

  describe ".call" do
    let(:user) { create(:user) }

    it "creates a new participant_identity record" do
      expect {
        service.call(user:)
      }.to change { ParticipantIdentity.count }.by(1)
    end

    it "populates the new identity with the details from the user" do
      identity = service.call(user:)
      expect(identity.user).to eq(user)
      expect(identity.email).to eq(user.email)
      expect(identity.external_identifier).to eq(user.id)
    end

    it "sets the origin to :ecf" do
      identity = service.call(user:)
      expect(identity).to be_ecf_origin
    end

    context "when the origin is specified as :npq" do
      it "sets the origin to :npq" do
        identity = service.call(user:, origin: :npq)
        expect(identity).to be_npq_origin
      end
    end

    context "when the user has existing participant_profiles", :with_default_schedules do
      context "when no existing identity already exists" do
        let!(:mentor_profile) { create(:mentor, :eligible_for_funding, user:) }
        let!(:npq_profile)    { create(:npq_participant_profile, user:) }

        it "adds the profiles to the new identity" do
          identity = service.call(user:)
          expect(identity.participant_profiles).to match_array [mentor_profile, npq_profile]
        end
      end

      context "when the existing profiles belong to another identity" do
        let(:ect)                { create(:mentor, :eligible_for_funding, user:) }
        let(:exisiting_identity) { ect.participant_identities.first }
        let!(:mentor_profile)    { create(:mentor, :eligible_for_funding, trn: ect.teacher_profile.trn).tap { |pp| pp.update!(teacher_profile: ect.teacher_profile) } }
        let(:npq_profile)        { create(:npq_participant_profile,       trn: ect.teacher_profile.trn, user:) }

        it "does not add the profiles to the new identity" do
          pending "this may not happen"
          expect(mentor_profile.participant_identity.participant_profiles).to be_empty
          # expect(exisiting_identity.participant_profiles).to match_array [mentor_profile, npq_profile]
        end
      end
    end

    context "when a profile for the users email address already exists" do
      let!(:identity) { create(:participant_identity, user:) }

      it "does not create a new identity record" do
        expect {
          service.call(user:)
        }.not_to change { ParticipantIdentity.count }
      end

      it "returns the existing identity record" do
        expect(service.call(user:)).to eq(identity)
      end
    end

    context "when used to create an additional sign-in account" do
      let!(:identity) { create(:participant_identity, user:) }

      it "creates a new identity record for the user" do
        expect {
          service.call(user:, email: "login2@example.com")
        }.to change { user.participant_identities.count }.by 1
      end

      it "generates a new external_identifier" do
        new_identity = service.call(user:, email: "login2@example.com")
        expect(new_identity.external_identifier).to be_present
        expect(new_identity.external_identifier).not_to eq user.id
      end

      context "when the user has existing profiles", :with_default_schedules do
        let(:teacher_profile) { create(:teacher_profile, user:) }
        let!(:mentor_profile) { create(:mentor, user: teacher_profile.user, participant_identity: identity) }
        let!(:npq_profile) { create(:npq_participant_profile, teacher_profile:, participant_identity: identity) }

        it "does not update any of the users participant_profiles" do
          new_identity = service.call(user:, email: "login2@example.com")
          expect(new_identity.reload.participant_profiles).to be_empty
        end
      end
    end
  end
end
