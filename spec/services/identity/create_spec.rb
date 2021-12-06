# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Create do
  subject(:service) { described_class }

  describe ".call" do
    let(:user) { create(:user) }

    it "creates a new participant_identity record" do
      expect {
        service.call(user: user)
      }.to change { ParticipantIdentity.count }.by(1)
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

    context "when a profile for the users email address already exists" do
      let!(:identity) { create(:participant_identity, user: user) }

      it "does not create a new identity record" do
        expect {
          service.call(user: user)
        }.not_to change { ParticipantIdentity.count }
      end

      it "returns the existing identity record" do
        expect(service.call(user: user)).to eq(identity)
      end
    end
  end
end
