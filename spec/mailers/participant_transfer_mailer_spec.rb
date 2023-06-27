# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantTransferMailer, type: :mailer do
  let(:participant_profile)   { create(:ect) }
  let(:induction_record)      { participant_profile.current_induction_record }
  let(:lead_provider_profile) { create(:lead_provider_profile) }

  describe "#participant_transfer_in_notification" do
    let(:participant_transfer_in_notification) do
      ParticipantTransferMailer.with(
        induction_record:,
      ).participant_transfer_in_notification
    end

    it "renders the right headers" do
      expect(participant_transfer_in_notification.from).to eq(["mail@example.com"])
      expect(participant_transfer_in_notification.to).to eq([induction_record.preferred_identity.email])
    end
  end

  describe "#participant_transfer_out_notification" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }
    let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
    let(:participant_transfer_out_notification) do
      ParticipantTransferMailer.with(
        induction_record:,
      ).participant_transfer_out_notification
    end

    it "renders the right headers" do
      expect(participant_transfer_out_notification.from).to eq(["mail@example.com"])
      expect(participant_transfer_out_notification.to).to eq([induction_record.preferred_identity.email])
    end
  end

  describe "#provider_transfer_in_notification" do
    let(:provider_transfer_in_notification) do
      ParticipantTransferMailer.with(
        induction_record:,
        lead_provider_profile:,
      ).provider_transfer_in_notification
    end

    it "renders the right headers" do
      expect(provider_transfer_in_notification.from).to eq(["mail@example.com"])
      expect(provider_transfer_in_notification.to).to eq([lead_provider_profile.user.email])
    end
  end

  describe "#provider_transfer_out_notification" do
    let(:provider_transfer_out_notification) do
      ParticipantTransferMailer.with(
        induction_record:,
        lead_provider_profile:,
      ).provider_transfer_out_notification
    end

    it "renders the right headers" do
      expect(provider_transfer_out_notification.from).to eq(["mail@example.com"])
      expect(provider_transfer_out_notification.to).to eq([lead_provider_profile.user.email])
    end
  end

  describe "#provider_new_school_transfer_notification" do
    let(:provider_new_school_transfer_notification) do
      ParticipantTransferMailer.with(
        induction_record:,
        lead_provider_profile:,
      ).provider_new_school_transfer_notification
    end

    it "renders the right headers" do
      expect(provider_new_school_transfer_notification.from).to eq(["mail@example.com"])
      expect(provider_new_school_transfer_notification.to).to eq([lead_provider_profile.user.email])
    end
  end

  describe "#provider_existing_school_transfer_notification" do
    let(:provider_existing_school_transfer_notification) do
      ParticipantTransferMailer.with(
        induction_record:,
        lead_provider_profile:,
      ).provider_existing_school_transfer_notification
    end

    it "renders the right headers" do
      expect(provider_existing_school_transfer_notification.from).to eq(["mail@example.com"])
      expect(provider_existing_school_transfer_notification.to).to eq([lead_provider_profile.user.email])
    end
  end
end
