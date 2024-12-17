# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::ChangeToPending do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  let(:npq_application) { create(:npq_application, :eligible_for_funding, application_status, npq_lead_provider:) }
  let(:participant_profile) { npq_application.profile }

  subject { described_class.new(npq_application:) }

  describe "#call" do
    context "when application has already been accepted" do
      let(:application_status) { :accepted }

      it "changes to pending", :aggregate_failures do
        subject.call

        npq_application.reload
        expect(npq_application).to be_pending
        expect(npq_application.profile).to be_nil
      end
    end

    context "when application has already been rejected" do
      let(:application_status) { :accepted }

      before { described_class.new(npq_application:).call }

      it "changes to pending" do
        subject.call

        npq_application.reload
        expect(npq_application).to be_pending
        expect(npq_application.profile).to be_nil
      end
    end

    context "when application has a schedule changed" do
      let(:application_status) { :accepted }

      before do
        participant_profile.participant_profile_schedules.create!(schedule: participant_profile.schedule)
        described_class.new(npq_application:).call
      end

      it "changes to pending" do
        subject.call

        npq_application.reload
        expect(npq_application).to be_pending
        expect(npq_application.profile).to be_nil
        expect(ParticipantProfileSchedule.where(participant_profile_id: participant_profile.id)).to be_empty
      end
    end

    context "when application has it's state changed" do
      let(:application_status) { :accepted }

      before do
        participant_profile.participant_profile_states.create!(state: "active")
        described_class.new(npq_application:).call
      end

      it "changes to pending" do
        subject.call

        npq_application.reload
        expect(npq_application).to be_pending
        expect(npq_application.profile).to be_nil
        expect(ParticipantProfileState.where(participant_profile_id: participant_profile.id)).to be_empty
      end
    end
  end
end
