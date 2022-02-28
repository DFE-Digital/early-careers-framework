# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Create do
  subject(:service) { described_class }

  describe ".call" do
    let(:user) { create(:user) }

    it "creates a new participant_identity record" do
      expect {
        service.call(user: user)
      }.to change { Identity.count }.by(1)
    end

    it "populates the new identity with the details from the user" do
      identity = service.call(user: user)
      expect(identity.user).to eq(user)
      expect(identity.email).to eq(user.email)
      expect(identity.external_identifier).to eq(user.id)
    end

    it "sets the origin to :ecf" do
      identity = service.call(user: user)
      expect(identity).to be_ecf_origin
    end

    context "when the origin is specified as :npq" do
      it "sets the origin to :npq" do
        identity = service.call(user: user, origin: :npq)
        expect(identity).to be_npq_origin
      end
    end

    context "when the user has existing participant_profiles" do
      let(:teacher_profile) { create(:teacher_profile, user: user) }
      let!(:mentor_profile) { create(:mentor_participant_profile, teacher_profile: teacher_profile) }
      let!(:npq_profile) { create(:npq_participant_profile, teacher_profile: teacher_profile) }

      it "adds the profiles to the new identity" do
        identity = service.call(user: user)
        expect(identity.participant_profiles).to match_array [mentor_profile, npq_profile]
      end

      context "when the existing profiles belong to another identity" do
        let(:id1) { create(:identity) }

        before do
          id1.update!(user: user)
          mentor_profile.update!(participant_identity: id1)
          npq_profile.update!(participant_identity: id1)
        end

        it "does not add the profiles to the new identity" do
          identity = service.call(user: user)
          expect(identity.participant_profiles).to be_empty
          expect(id1.participant_profiles).to match_array [mentor_profile, npq_profile]
        end
      end
    end

    context "when a profile for the users email address already exists" do
      let!(:identity) { create(:identity, user: user) }

      it "does not create a new identity record" do
        expect {
          service.call(user: user)
        }.not_to change { Identity.count }
      end

      it "returns the existing identity record" do
        expect(service.call(user: user)).to eq(identity)
      end
    end
  end
end
