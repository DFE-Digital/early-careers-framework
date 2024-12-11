# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::RetryContinueTraining do
  let(:cohort) { Cohort.find_by_start_year(2021) || create(:cohort, start_year: 2021) }
  let(:participant_profile) { create(:ect, cohort:) }
  let(:target_cohort_start_year) { Cohort.active_registration_cohort.start_year }
  let(:old_error_message) { "Can't change cohort" }
  let(:service) { described_class.new(participant_profile:) }

  before do
    ContinueTrainingCohortChangeError.create!(participant_profile:, message: old_error_message)
  end

  describe "#call" do
    context "when the participant is no longer eligible to continue training" do
      before do
        allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?).and_return(false)
      end

      it "does not persist an error for the participant" do
        expect { service.call }.to change(ContinueTrainingCohortChangeError, :count).from(1).to(0)
      end
    end

    context "when the retry fails" do
      let(:new_error_message) { "Cohort change failed" }
      let(:errors) { double(full_messages: [new_error_message]) }

      before do
        allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?).and_return(true)
        allow(Induction::AmendParticipantCohort).to receive(:new).with(participant_profile:,
                                                                       source_cohort_start_year: 2021,
                                                                       target_cohort_start_year:)
                                                                 .and_return(double(save: false, errors:))
      end

      it "persist a new error for the participant" do
        expect { service.call }.to change { ContinueTrainingCohortChangeError.pluck(:message) }
                                     .from([old_error_message])
                                     .to([new_error_message])
      end
    end

    context "when the retry succeeds" do
      before do
        allow(Induction::AmendParticipantCohort).to receive(:new).with(participant_profile:,
                                                                       source_cohort_start_year: 2021,
                                                                       target_cohort_start_year:)
                                                                 .and_return(double(save: true))
      end

      it "does not persist an error for the participant" do
        expect { service.call }.to change(ContinueTrainingCohortChangeError, :count).from(1).to(0)
      end
    end
  end
end
