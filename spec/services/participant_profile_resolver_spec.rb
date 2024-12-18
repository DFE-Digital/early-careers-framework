# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfileResolver do
  describe "#call" do
    let!(:ect_profile) { create(:ect) }
    let(:user) { ect_profile.user }
    let!(:mentor_profile) { create(:mentor, user:) }
    let(:participant_identity) { user.participant_identities.first }

    subject { described_class.call(participant_identity:, course_identifier:) }

    context "when course identifier is mentor" do
      let(:course_identifier) { "ecf-mentor" }

      it "correctly selects Mentor profile" do
        expect(subject).to eql(mentor_profile)
      end
    end

    context "when course identifier is induction" do
      let(:course_identifier) { "ecf-induction" }

      it "correctly selects ECT profile" do
        expect(subject).to eql(ect_profile)
      end
    end

    context "when participant identity is nil" do
      let(:participant_identity) { nil }
      let(:course_identifier) { "ecf-induction" }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
