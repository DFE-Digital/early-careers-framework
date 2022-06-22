# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantTransferMailer, type: :mailer do
  describe "#participant_transfer_in_notification" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }
    let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
    let(:participant_transfer_in_notification) do
      ParticipantTransferMailer.participant_transfer_in_notification(
        induction_record:,
      )
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
      ParticipantTransferMailer.participant_transfer_out_notification(
        induction_record:,
      )
    end

    it "renders the right headers" do
      expect(participant_transfer_out_notification.from).to eq(["mail@example.com"])
      expect(participant_transfer_out_notification.to).to eq([induction_record.preferred_identity.email])
    end
  end

  describe "#provider_transfer_in_notification" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }
    let(:lead_provider_profile) { create(:lead_provider_profile) }
    let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
    let(:provider_transfer_in_notification) do
      ParticipantTransferMailer.provider_transfer_in_notification(
        induction_record:,
        lead_provider_profile:,
      )
    end

    it "renders the right headers" do
      expect(provider_transfer_in_notification.from).to eq(["mail@example.com"])
      expect(provider_transfer_in_notification.to).to eq([lead_provider_profile.user.email])
    end
  end

  describe "#provider_transfer_out_notification" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }
    let(:lead_provider_profile) { create(:lead_provider_profile) }
    let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
    let(:provider_transfer_out_notification) do
      ParticipantTransferMailer.provider_transfer_out_notification(
        induction_record:,
        lead_provider_profile:,
      )
    end

    it "renders the right headers" do
      expect(provider_transfer_out_notification.from).to eq(["mail@example.com"])
      expect(provider_transfer_out_notification.to).to eq([lead_provider_profile.user.email])
    end
  end

  describe "#provider_new_school_transfer_notification" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }
    let(:lead_provider_profile) { create(:lead_provider_profile) }
    let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
    let(:provider_new_school_transfer_notification) do
      ParticipantTransferMailer.provider_new_school_transfer_notification(
        induction_record:,
        lead_provider_profile:,
      )
    end

    it "renders the right headers" do
      expect(provider_new_school_transfer_notification.from).to eq(["mail@example.com"])
      expect(provider_new_school_transfer_notification.to).to eq([lead_provider_profile.user.email])
    end
  end

  describe "#provider_existing_school_transfer_notification" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }
    let(:lead_provider_profile) { create(:lead_provider_profile) }
    let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
    let(:provider_existing_school_transfer_notification) do
      ParticipantTransferMailer.provider_existing_school_transfer_notification(
        induction_record:,
        lead_provider_profile:,
      )
    end

    it "renders the right headers" do
      expect(provider_existing_school_transfer_notification.from).to eq(["mail@example.com"])
      expect(provider_existing_school_transfer_notification.to).to eq([lead_provider_profile.user.email])
    end
  end
end
