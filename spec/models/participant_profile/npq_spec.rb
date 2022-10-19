# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::NPQ, :with_default_schedules, type: :model do
  let(:npq_application) { create(:npq_application) }
  let(:profile) do
    NPQ::Accept.call(npq_application:)
    npq_application.reload.profile
  end
  describe "#push_profile_to_big_query" do
    context "on create" do
      it "pushes profile to BigQuery" do
        allow(NPQ::StreamBigQueryProfileJob).to receive(:perform_later).and_call_original
        profile
        expect(NPQ::StreamBigQueryProfileJob).to have_received(:perform_later).with(profile_id: profile.id)
      end
    end

    context "on update" do
      it "pushes profile to BigQuery" do
        allow(NPQ::StreamBigQueryProfileJob).to receive(:perform_later).and_call_original
        profile
        profile.update!(school_urn: "123456")
        expect(NPQ::StreamBigQueryProfileJob).to have_received(:perform_later).with(profile_id: profile.id).twice
      end
    end
  end

  describe "#withdrawn_for" do
    let(:cpd_lead_provider) { subject.npq_application.npq_lead_provider.cpd_lead_provider }

    context "when participant is withdrawn" do
      subject { create(:npq_participant_profile, :withdrawn) }

      it "returns true" do
        expect(subject.reload.withdrawn_for?(cpd_lead_provider:)).to be true
      end
    end

    context "when participant is not withdrawn" do
      subject { create(:npq_participant_profile) }

      it "returns false" do
        expect(subject.reload.withdrawn_for?(cpd_lead_provider:)).to be false
      end
    end
  end

  describe "#deferred_for" do
    let(:cpd_lead_provider) { subject.npq_application.npq_lead_provider.cpd_lead_provider }

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
    let(:lead_provider) do
      subject.npq_application.npq_lead_provider
    end

    subject { create(:npq_participant_profile) }

    it "returns the relevant induction record for that profile" do
      expect(subject.record_to_serialize_for(lead_provider:)).to eq(subject.user)
    end
  end
end
