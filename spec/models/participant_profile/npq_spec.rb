# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::NPQ, type: :model do
  let(:profile) { create(:npq_participant_profile) }
  let(:cpd_lead_provider) { nil }

  describe "#withdrawn_for" do
    context "when participant is not withdrawn" do
      subject { create(:npq_participant_profile) }

      it "returns false" do
        expect(subject.reload.withdrawn_for?(cpd_lead_provider:)).to be false
      end
    end
  end

  describe "#active_for" do
    context "when participant is active" do
      subject { create(:npq_participant_profile) }

      it "returns true" do
        expect(subject.reload.active_for?(cpd_lead_provider:)).to be true
      end
    end
  end

  describe "#deferred_for" do
    context "when participant is deferred" do
      subject { create(:npq_participant_profile, :deferred) }

      it "returns true" do
        expect(subject.reload.deferred_for?(cpd_lead_provider:)).to be true
      end
    end

    context "when participant is not deferred" do
      subject { create(:npq_participant_profile) }

      it "returns false" do
        expect(subject.reload.deferred_for?(cpd_lead_provider:)).to be false
      end
    end
  end

  describe "#record_to_serialize_for" do
    let(:lead_provider) { nil }

    subject { create(:npq_participant_profile) }

    it "returns the profile user" do
      expect(subject.record_to_serialize_for(lead_provider:)).to eq(subject.user)
    end
  end
end
