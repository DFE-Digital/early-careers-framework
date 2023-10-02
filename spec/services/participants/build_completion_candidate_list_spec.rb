# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::BuildCompletionCandidateList do
  let(:cohort_21) { create(:seed_cohort, start_year: 2021) }
  let(:cohort_22) { create(:seed_cohort, start_year: 2022) }
  let(:cohort_23) { create(:seed_cohort, start_year: 2023) }

  let!(:ect_21) { make_ect_for_cohort(cohort_21) }
  let!(:ect_22) { make_ect_for_cohort(cohort_22) }
  let!(:ect_23) { make_ect_for_cohort(cohort_23) }

  subject(:service_call) { described_class.call }

  describe "#call" do
    it "adds eligible ECTs from 2021 and 2022 to the list" do
      expect { service_call }.to change { CompletionCandidate.count }.by(2)
    end

    it "does not add ECTs from 2023" do
      service_call
      expect(CompletionCandidate.all).not_to include ect_23
    end

    context "when an ECT does not have an induction start date" do
      before do
        ect_22.update!(induction_start_date: nil)
      end

      it "does not add them to the list" do
        service_call
        expect(CompletionCandidate.all).not_to include ect_22
      end
    end
  end

  def make_ect_for_cohort(cohort)
    start_date = Date.new(cohort.start_year, 9, 1)
    travel_to(start_date) do
      schedule = create(:seed_finance_schedule, cohort:)
      create(:ect_participant_profile, schedule:, induction_start_date: start_date)
    end
  end
end
