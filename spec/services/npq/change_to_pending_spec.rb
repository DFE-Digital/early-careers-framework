# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::ChangeToPending, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  let(:npq_application) { create(:npq_application, :eligible_for_funding, application_status, npq_lead_provider:) }
  let(:participant_profile) { npq_application.profile }

  let(:participant_declaration) { create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:) }

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

    # Should fail
    %w[eligible payable paid awaiting_clawback].each do |dec_state|
      context "accepted application with #{dec_state} declaration" do
        let(:application_status) { :accepted }
        let!(:participant_declaration) { create(:npq_participant_declaration, dec_state, participant_profile:, cpd_lead_provider:) }

        it "returns error", :aggregate_failures do
          subject.call

          npq_application.reload
          expect(npq_application).to be_accepted
          expect(npq_application.errors[:lead_provider_approval_status]).to include("There are already declarations for this participant on this course, please ask provider to void and/or clawback any declarations they have made before attempting to reset the application.")
        end
      end
    end

    #  Should succeed
    %w[submitted voided ineligible].each do |dec_state|
      context "accepted application with #{dec_state} declaration" do
        let(:application_status) { :accepted }
        let!(:participant_declaration) { create(:npq_participant_declaration, dec_state, participant_profile:, cpd_lead_provider:) }

        it "changes to pending", :aggregate_failures do
          subject.call

          npq_application.reload
          expect(npq_application).to be_pending
          expect(npq_application.errors[:lead_provider_approval_status]).to_not be_present
        end
      end
    end
  end
end
