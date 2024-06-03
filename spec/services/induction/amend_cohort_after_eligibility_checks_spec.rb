# frozen_string_literal: true

RSpec.describe Induction::ReviewCohortAfterEligibilityChecks do
  describe "#call" do
    let(:participant_profile) { create(:ect, status, cohort: Cohort.previous) }

    subject(:form) do
      described_class.new(participant_profile:)
    end

    context "when the participant is not eligible for funding" do
      let(:status) { :ineligible }

      before do
        participant_profile.schedule.cohort.update!(payments_frozen_at: Date.yesterday)
      end

      it "do not change the participant's cohort" do
        expect { subject.call }.not_to change { participant_profile.schedule.cohort.start_year }
      end
    end

    context "when the participant eligibility reason is other than 'none'" do
      let(:status) { :eligible_for_funding }

      before do
        participant_profile.schedule.cohort.update!(payments_frozen_at: Date.yesterday)
        participant_profile.ecf_participant_eligibility.reason = "no_qts"
      end

      it "do not change the participant's cohort" do
        expect { subject.call }.not_to change { participant_profile.schedule.cohort.start_year }
      end
    end

    context "when the participant is not in a payments-frozen cohort" do
      let(:status) { :eligible_for_funding }

      it "do not change the participant's cohort" do
        expect { subject.call }.not_to change { participant_profile.schedule.cohort.start_year }
      end
    end

    context "when the participant is in a payments-frozen cohort" do
      let(:status) { :eligible_for_funding }
      let(:source_cohort_start_year) { Cohort.previous.start_year }
      let(:target_cohort_start_year) { Cohort.active_registration_cohort.start_year }

      before do
        participant_profile.schedule.cohort.update!(payments_frozen_at: Date.yesterday)
        allow(Induction::AmendParticipantCohort).to receive(:new).and_return(double(save: true))
        subject.call
      end

      it "try and place them in the currently active registration cohort" do
        expect(Induction::AmendParticipantCohort).to have_received(:new).with(participant_profile:,
                                                                              source_cohort_start_year:,
                                                                              target_cohort_start_year:)
      end
    end
  end
end
