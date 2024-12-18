# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::NPQ, type: :model do
  let(:npq_application) { create(:npq_application) }
  let(:profile) do
    NPQ::Application::Accept.new(npq_application:).call
    npq_application.reload.profile
  end

  describe "#withdrawn_for" do
    let(:cpd_lead_provider) { subject.npq_application.npq_lead_provider.cpd_lead_provider }

    context "when participant is not withdrawn" do
      subject { create(:npq_participant_profile) }

      it "returns false" do
        expect(subject.reload.withdrawn_for?(cpd_lead_provider:)).to be false
      end
    end
  end

  describe "#active_for" do
    let(:cpd_lead_provider) { subject.npq_application.npq_lead_provider.cpd_lead_provider }

    context "when participant is active" do
      subject { create(:npq_participant_profile) }

      it "returns true" do
        expect(subject.reload.active_for?(cpd_lead_provider:)).to be true
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

    it "returns the profile user" do
      expect(subject.record_to_serialize_for(lead_provider:)).to eq(subject.user)
    end
  end

  describe "#fundable?" do
    context "when it is eligible_for_funding" do
      let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: nil) }
      subject { profile }

      it { is_expected.to be_fundable }
    end

    context "when it is not eligible_for_funding" do
      let(:npq_application) { create(:npq_application, eligible_for_funding: false, funded_place: nil) }
      subject { profile }

      it { is_expected.not_to be_fundable }
    end

    context "when it is eligible_for_funding but has no funded place" do
      let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: false) }
      subject { profile }

      it { is_expected.not_to be_fundable }
    end

    context "when it is eligible_for_funding but and has a funded place" do
      let(:npq_application) { create(:npq_application, eligible_for_funding: true, funded_place: true) }
      subject { profile }

      it { is_expected.to be_fundable }
    end

    context "when it is not eligible_for_funding but and has a funded place" do
      let(:npq_application) { create(:npq_application, eligible_for_funding: false, funded_place: false) }
      subject { profile }

      it { is_expected.not_to be_fundable }
    end
  end
end
