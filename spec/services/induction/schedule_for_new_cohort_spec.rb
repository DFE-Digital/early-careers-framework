# frozen_string_literal: true

RSpec.describe Induction::ScheduleForNewCohort do
  describe "#call" do
    let(:cohort) { Cohort.current }
    let(:schedule_identifier) { "ecf-standard-september" }
    let(:schedule) { double(Finance::Schedule::ECF, schedule_identifier:) }
    let(:cohort_changed_after_payments_frozen) { false }
    let(:service) { described_class.call(cohort:, induction_record:, cohort_changed_after_payments_frozen:) }

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
      let(:induction_record) { double(InductionRecord, cohort: Cohort.previous, schedule_identifier:) }
      let(:new_schedule) { double(Finance::Schedule::ECF, schedule_identifier:, cohort:) }

      context "when cohort_changed_after_payments_frozen is true" do
        let(:cohort_changed_after_payments_frozen) { true }

        context "when the ecf-extended-september schedule in the cohort exists" do
          let(:default_schedule) { double(Finance::Schedule::ECF, cohort:, schedule_identifier: "ecf-extended-september") }

          before do
            allow(Finance::Schedule::ECF).to receive(:find_by)
                                               .with(cohort:, schedule_identifier: "ecf-extended-september")
                                               .and_return(default_schedule)
          end

          it "return the 'ecf-extended-september' schedule for the cohort" do
            expect(service.schedule_identifier).to eq("ecf-extended-september")
            expect(service.cohort).to eq(cohort)
          end
        end

        context "when the ecf-extended-september schedule in the cohort does not exist" do
          let(:default_schedule) { double(Finance::Schedule::ECF, cohort:, schedule_identifier: "ecf-default") }

          before do
            allow(Finance::Schedule::ECF).to receive(:find_by)
                                               .with(cohort:, schedule_identifier: "ecf-extended-september")
            allow(Finance::Schedule::ECF).to receive(:default_for).with(cohort:).and_return(default_schedule)
          end

          it "return the default schedule for the cohort" do
            expect(service.schedule_identifier).to eq("ecf-default")
            expect(service.cohort).to eq(cohort)
          end
        end
      end

      context "when cohort_changed_after_payments_frozen is false" do
        let(:cohort_changed_after_payments_frozen) { false }

        context "when a schedule in the cohort exists with the same schedule-identifier as the induction record's schedule" do
          let(:default_schedule) { double(Finance::Schedule::ECF, cohort:, schedule_identifier:) }

          before do
            allow(Finance::Schedule::ECF).to receive(:find_by)
                                               .with(cohort:, schedule_identifier:)
                                               .and_return(default_schedule)
          end

          it "return it" do
            expect(service.schedule_identifier).to eq(schedule_identifier)
            expect(service.cohort).to eq(cohort)
          end
        end

        context "when a schedule in the cohort do not exist with the same schedule-identifier as the induction record's schedule" do
          let(:default_schedule) { double(Finance::Schedule::ECF, cohort:, schedule_identifier: "ecf-default") }

          before do
            allow(Finance::Schedule::ECF).to receive(:find_by).with(cohort:, schedule_identifier:)
            allow(Finance::Schedule::ECF).to receive(:default_for).with(cohort:).and_return(default_schedule)
          end

          it "return the default schedule for the cohort" do
            expect(service.schedule_identifier).to eq("ecf-default")
            expect(service.cohort).to eq(cohort)
          end
        end
      end
    end
  end
end
