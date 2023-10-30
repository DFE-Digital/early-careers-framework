# frozen_string_literal: true

require "rails_helper"

describe ChangeMilestoneDate, type: :model do
  let(:schedule) { create(:ecf_schedule, schedule_identifier: "test-schedule") }
  let(:schedule_identifier) { schedule.schedule_identifier }
  let(:milestone_number) { 1 }
  let(:start_year) { schedule.cohort.start_year }
  let(:milestone) { schedule.milestones.first }
  let(:new_milestone_date) { (milestone.milestone_date || Date.new) - 1.week }
  let(:new_start_date) { (milestone.start_date || Date.new) + 1.week }

  let(:instance) do
    described_class.new(
      schedule_identifier:,
      start_year:,
      milestone_number:,
      new_milestone_date:,
      new_start_date:,
    )
  end

  describe "validations" do
    let(:errors) do
      instance.valid?
      instance.errors
    end

    describe "milestone validation" do
      it { expect(errors).not_to have_key(:milestone) }

      context "when the milestone does not have a milestone_date" do
        before { milestone.update!(milestone_date: nil) }

        it { expect(errors[:milestone]).to include(/does not currently have a milestone_date/) }
      end

      context "when the milestone does not have a start_date" do
        before { milestone.update!(start_date: nil) }

        it { expect(errors[:milestone]).to include(/does not currently have a start_date/) }
      end

      context "when the milestone could not be found" do
        let(:milestone_number) { 99 }

        it { expect(errors[:milestone]).to include(/could not be matched/) }
      end
    end

    describe "new_start_date and new_milestone_date validation" do
      let(:participant_profile) { create(:ect, schedule:, lead_provider:) }
      let(:lead_provider) { partnership.lead_provider }
      let(:partnership) { create(:partnership) }
      let(:cpd_lead_provider) { lead_provider.cpd_lead_provider }

      before { create(:induction_record, participant_profile:, schedule:, partnership:) }

      it { is_expected.to validate_presence_of(:new_milestone_date).with_message(/must be specified/) }
      it { is_expected.to validate_presence_of(:new_start_date).with_message(/must be specified/) }

      context "when the declarations fall within the new milestone dates" do
        before do
          travel_to new_milestone_date do
            create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:, declaration_date: new_milestone_date - 1.day)
          end
        end

        it { expect(errors).not_to have_key(:new_milestone_date) }
      end

      context "when a declaration falls outside the new milestone dates" do
        let!(:declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:, declaration_date: new_start_date - 1.day) }
        let(:declaration_date) { declaration.declaration_date }

        it { expect(errors[:new_milestone_date]).to include(/declaration date #{declaration_date} falls outside of range/) }
      end

      described_class::DECLARATION_STATES_TO_IGNORE.each do |state|
        context "when a #{state} declaration falls outside the new milestone dates" do
          before { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:, state:, declaration_date: new_start_date - 1.day) }

          it { expect(errors).not_to have_key(:new_milestone_date) }
        end
      end
    end
  end

  describe "#change_date!" do
    subject(:change_date) { instance.change_date! }

    it { expect { change_date }.to change { milestone.reload.start_date }.to(new_start_date) }
    it { expect { change_date }.to change { milestone.reload.milestone_date }.to(new_milestone_date) }

    context "when new_start_date is nil" do
      let(:new_start_date) { nil }

      it { expect { change_date }.not_to change { milestone.reload.start_date } }
    end

    context "when new_milestone_date is nil" do
      let(:new_milestone_date) { nil }

      it { expect { change_date }.not_to change { milestone.reload.milestone_date } }
    end

    context "when the date change is not valid" do
      before { milestone.update!(milestone_date: nil) }

      it { expect { change_date }.to raise_error(described_class::DateCannotBeChangedError, /does not currently have a milestone_date/) }
    end
  end
end
