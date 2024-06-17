# frozen_string_literal: true

RSpec.describe Induction::ScheduleForNewCohort do
  describe "#call" do
    let(:cohort) { Cohort.current }
    let(:schedule_identifier) { "ecf-standard-september" }
    let(:service) { described_class.call(cohort:, induction_record:) }

    context "when induction record is nil" do
      let(:default_schedule) { double(Finance::Schedule::ECF) }
      let(:induction_record) {}

      before do
        allow(Finance::Schedule::ECF).to receive(:default_for).with(cohort:).and_return(default_schedule)
      end

      it "return the default schedule for the cohort" do
        expect(service).to eq(default_schedule)
      end
    end

    context "when the induction record is already in the cohort" do
      let(:schedule) { double(Finance::Schedule::ECF, schedule_identifier:) }
      let(:induction_record) { double(InductionRecord, cohort:, schedule:) }

      it "return the induction record schedule" do
        expect(service).to eq(induction_record.schedule)
      end
    end

    context "when the induction record is not in the cohort" do
      let(:schedule) { double(Finance::Schedule::ECF, schedule_identifier:) }
      let(:new_schedule) { double(Finance::Schedule::ECF, schedule_identifier:, cohort:) }
      let(:induction_record) { double(InductionRecord, cohort: Cohort.previous, schedule_identifier:) }

      before do
        allow(Finance::Schedule::ECF).to receive(:find_by).with(cohort:, schedule_identifier:).and_return(new_schedule)
      end

      it "return a new schedule in the cohort keeping the same schedule-identifier" do
        expect(service).to eql(new_schedule)
      end
    end
  end
end
