# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::ChangeToPending do
  let!(:cohort) { create :cohort }
  let!(:schedule) { create :npq_leadership_schedule, cohort: }
  let(:npq_course) { create :npq_course, identifier: "npq-senior-leadership" }
  let(:npq_lead_provider) { create :npq_lead_provider }

  let!(:npq_application) do
    create(
      :npq_application,
      application_status,
      npq_lead_provider:,
      npq_course:,
      cohort:,
    )
  end

  let!(:participant_profile) { npq_application.profile }

  let!(:participant_declaration) do
    create(
      :npq_participant_declaration,
      declaration_type: "started",
      user: npq_application.user,
      participant_profile:,
      course_identifier: npq_course.identifier,
      state: "submitted",
    )
  end

  subject do
    described_class.new(npq_application:)
  end

  describe "#call" do
    context "when application has already been accepted" do
      let(:application_status) { :accepted }

      it "changes to pending" do
        subject.call
        npq_application.reload
        expect(npq_application).to be_pending
        expect(npq_application.profile).to be_nil
      end
    end

    context "when application has already been rejected" do
      let(:application_status) { :rejected }
      let!(:participant_profile) { create(:npq_participant_profile, npq_application:) }

      it "changes to pending" do
        subject.call
        npq_application.reload
        expect(npq_application).to be_pending
        expect(npq_application.profile).to be_nil
      end
    end

    # Should fail
    %w[eligible payable paid awaiting_clawback].each do |dec_state|
      context "accepted application with #{dec_state} declaration" do
        let(:application_status) { :accepted }
        let!(:participant_declaration) do
          create(
            :npq_participant_declaration,
            declaration_type: "started",
            user: npq_application.user,
            participant_profile:,
            course_identifier: npq_course.identifier,
            state: dec_state,
          )
        end

        it "returns error" do
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
        let!(:participant_declaration) do
          create(
            :npq_participant_declaration,
            declaration_type: "started",
            user: npq_application.user,
            participant_profile:,
            course_identifier: npq_course.identifier,
            state: dec_state,
          )
        end

        it "changes to pending" do
          subject.call
          npq_application.reload
          expect(npq_application).to be_pending
          expect(npq_application.errors[:lead_provider_approval_status]).to_not be_present
        end
      end
    end
  end
end
