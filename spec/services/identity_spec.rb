# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity do
  describe ".find_user_by" do
    context "when searching by email" do
      let(:user) { create(:user, email: "fred@example.com") }
      let!(:identity) { create(:participant_identity, user: user, email: "charlie@example.com") }

      context "when a matching identity record exists" do
        it "returns the associated user record" do
          result = described_class.find_user_by(email: "charlie@example.com")
          expect(result).to eq user
        end
      end

      context "when a matching user record exists" do
        it "returns the user record" do
          result = described_class.find_user_by(email: "fred@example.com")
          expect(result).to eq user
        end
      end

      context "when a matching identity or user record is not found" do
        it "returns nil" do
          result = described_class.find_user_by(email: "arthur@example.com")
          expect(result).to be_nil
        end
      end
    end

    context "when searching by id" do
      let(:user) { create(:user) }
      let(:external_id) { SecureRandom.uuid }
      let!(:identity) { create(:participant_identity, user: user, external_identifier: external_id) }

      context "when a matching identity record exists" do
        it "returns the associated user record" do
          result = described_class.find_user_by(id: external_id)
          expect(result).to eq user
        end
      end

      context "when a matching user record exists" do
        it "returns the user record" do
          result = described_class.find_user_by(id: user.id)
          expect(result).to eq user
        end
      end

      context "when a matching identity or user record is not found" do
        it "returns nil" do
          result = described_class.find_user_by(id: SecureRandom.uuid)
          expect(result).to be_nil
        end
      end
    end

    context "when searching by other user attributes" do
      let!(:user) { create(:user, full_name: "Chester Thompson") }

      it "falls back to User.find_by" do
        result = described_class.find_user_by(full_name: "Chester Thompson")
        expect(result).to eq user
      end
    end
  end
end
