# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::ChangeToPending do
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

    describe "remove funded place" do
      let(:application_status) { :accepted }
      let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
      let(:npq_lead_provider) { create(:npq_lead_provider) }

      let(:statement) do
        create(
          :npq_statement,
          :next_output_fee,
          cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
          cohort: npq_application.cohort,
        )
      end
      let(:funding_cap) { 10 }
      let!(:npq_contract) do
        create(
          :npq_contract,
          npq_lead_provider:,
          cohort: statement.cohort,
          course_identifier: npq_course.identifier,
          version: statement.contract_version,
          funding_cap:,
        )
      end

      context "when the feature flag is not active" do
        before { FeatureFlag.deactivate(:npq_capping) }

        it "does not change funded place" do
          npq_application.update!(funded_place: true)

          expect { subject.call }.not_to change(npq_application, :funded_place)
        end
      end

      context "when the feature flag is active" do
        before do
          FeatureFlag.activate(:npq_capping)
        end

        it "marks the funded place as nil if funded place is true" do
          npq_application.update!(funded_place: true)

          subject.call

          expect(npq_application.reload.funded_place).to eq(nil)
        end

        it "marks the funded place as nil if funded place is false" do
          npq_application.update!(funded_place: false)

          subject.call

          expect(npq_application.reload.funded_place).to eq(nil)
        end

        it "does not change `funded place` if funded place is nil" do
          npq_application.update!(funded_place: nil)

          subject.call

          expect { subject.call }.not_to change(npq_application, :funded_place)
        end
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
