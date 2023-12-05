# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::DedupeParticipant do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_application) { create(:npq_application, :eligible_for_funding, npq_lead_provider:) }
  let(:trn) { npq_application&.teacher_reference_number }
  let(:user) { npq_application&.user.presence || create(:user) }
  let!(:teacher_profile) { create(:teacher_profile, user:, trn:) }
  let!(:same_trn_teacher_profile) { create(:teacher_profile, trn:) }

  let(:params) do
    {
      npq_application:,
      trn:,
    }
  end

  subject(:service) { described_class.new(params) }

  describe "#call" do
    context "when the npq application is missing" do
      let(:npq_application) {}

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:npq_application)).to include("The npq application must be present")
      end
    end

    context "when the trn is missing" do
      let(:trn) {}

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:trn)).to include("The teacher reference number (TRN) must be present")
      end
    end

    context "when the from_user is missing" do
      before do
        allow(npq_application).to receive(:user_id).and_return(nil)
      end

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:from_user)).to include("The user to be deduped from must be present")
      end
    end

    context "when the to_user is missing" do
      before do
        same_trn_teacher_profile.update!(trn: "A23456")
      end

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:to_user)).to include("The user to be deduped to must be present")
      end
    end

    context "when the TRN has not been validated yet" do
      before do
        npq_application.update!(teacher_reference_number_verified: false)
      end

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:trn)).to include("Teacher reference number (TRN) has not been validated")
      end
    end

    context "when a dedupe with same users already took place" do
      before do
        user.participant_id_changes.create!(from_participant: user, to_participant: same_trn_teacher_profile.user)
      end

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:trn)).to include("Deduplication has already taken place from these users")
      end
    end

    context "with correct params" do
      it "is valid" do
        is_expected.to be_valid
      end

      it "calls Identity::Transfer with correct params" do
        expect(Identity::Transfer).to receive(:call).with(from_user: user, to_user: same_trn_teacher_profile.user)

        subject.call
      end
    end
  end
end
