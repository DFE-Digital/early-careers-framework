# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::CreateSchedule do
  describe "#call" do
    let!(:cohort) { FactoryBot.create :seed_cohort }
    let(:csv) { Tempfile.new("data.csv") }
    let(:path_to_csv) { csv.path }

    subject do
      described_class.new(path_to_csv:)
    end

    context "Invalid type" do
      before do
        csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
        csv.write "\n"
        csv.write "invalid,ecf-standard-september,ECF Standard September,#{cohort.start_year},Output 1 - Participant Start,started,#{cohort.start_year}/09/01,#{cohort.start_year}/11/30,#{cohort.start_year}/11/30"
        csv.close
      end

      it "raises an error" do
        expect { subject.call }.to raise_error(ArgumentError, "Invalid schedule type")
      end
    end

    context "ECF" do
      let(:klass) { Finance::Schedule::ECF }

      before do
        csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
        csv.write "\n"
        csv.write "ecf_standard,ecf-standard-september,ECF Standard September,#{cohort.start_year},Output 1 - Participant Start,started,#{cohort.start_year}/09/01,#{cohort.start_year}/11/30,#{cohort.start_year}/11/30"
        csv.close
      end

      context "new schedule" do
        it "creates a new schedule for the correct cohort" do
          original_schedules_count = klass.count
          subject.call
          expect(klass.count).to eql(original_schedules_count + 1)
          expect(klass.where(cohort:).count).to eql(1)

          schedule = klass.where(cohort:).first
          expect(schedule.name).to eql("ECF Standard September")

          milestone = schedule.milestones.first
          expect(milestone.name).to eql("Output 1 - Participant Start")
          expect(milestone.declaration_type).to eql("started")
          expect(milestone.start_date).to eql("#{cohort.start_year}/09/01".to_date)
          expect(milestone.milestone_date).to eql("#{cohort.start_year}/11/30".to_date)
          expect(milestone.payment_date).to eql("#{cohort.start_year}/11/30".to_date)

          schedule_milestone = schedule.schedule_milestones.first
          expect(schedule_milestone.name).to eql("Output 1 - Participant Start")
          expect(schedule_milestone.declaration_type).to eql("started")
        end
      end

      context "existing schedule" do
        let!(:schedule) { create(:ecf_schedule, name: "New ECF name", schedule_identifier: "ecf-standard-september", cohort:) }

        it "updates the name" do
          expect(klass.where(cohort:).count).to eql(1)
          expect(schedule.reload.name).to eql("New ECF name")
          subject.call
          expect(klass.where(cohort:).count).to eql(1)
          expect(schedule.reload.name).to eql("ECF Standard September")
        end
      end
    end

    context "NPQ" do
      let(:klass) { Finance::Schedule::NPQLeadership }

      before do
        csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
        csv.write "\n"
        csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,#{cohort.start_year},Output 1 - Participant Start,started,01/11/#{cohort.start_year},01/11/#{cohort.start_year},01/11/#{cohort.start_year}"
        csv.close
      end

      context "new schedule" do
        it "creates a new schedule for the correct cohort" do
          original_schedules_count = klass.count
          subject.call
          expect(klass.count).to eql(original_schedules_count + 1)
          expect(klass.where(cohort:).count).to eql(1)

          schedule = klass.where(cohort:).first
          expect(schedule.name).to eql("NPQ Leadership Autumn")

          milestone = schedule.milestones.first
          expect(milestone.name).to eql("Output 1 - Participant Start")
          expect(milestone.declaration_type).to eql("started")
          expect(milestone.start_date).to eql("01/11/#{cohort.start_year}".to_date)
          expect(milestone.milestone_date).to eql("01/11/#{cohort.start_year}".to_date)
          expect(milestone.payment_date).to eql("01/11/#{cohort.start_year}".to_date)

          schedule_milestone = schedule.schedule_milestones.first
          expect(schedule_milestone.name).to eql("Output 1 - Participant Start")
          expect(schedule_milestone.declaration_type).to eql("started")
        end
      end

      context "existing schedule" do
        let!(:schedule) { create(:npq_leadership_schedule, name: "New NPQ name", schedule_identifier: "npq-leadership-autumn", cohort:) }

        it "updates the name" do
          expect(schedule.type).to eql(klass.name)
          expect(klass.where(cohort:).count).to eql(1)
          expect(schedule.reload.name).to eql("New NPQ name")
          subject.call
          expect(klass.where(cohort:).count).to eql(1)
          expect(schedule.reload.name).to eql("NPQ Leadership Autumn")
        end
      end
    end
  end

  describe "#type_to_klass" do
    subject do
      described_class.new(path_to_csv: "test.csv")
    end

    it "returns correct schedule class for each type" do
      expect(subject.send(:type_to_klass, "npq_specialist")).to eql(Finance::Schedule::NPQSpecialist)
      expect(subject.send(:type_to_klass, "npq_leadership")).to eql(Finance::Schedule::NPQLeadership)
      expect(subject.send(:type_to_klass, "npq_aso")).to eql(Finance::Schedule::NPQSupport)
      expect(subject.send(:type_to_klass, "npq_ehco")).to eql(Finance::Schedule::NPQEhco)
      expect(subject.send(:type_to_klass, "ecf_standard")).to eql(Finance::Schedule::ECF)
      expect(subject.send(:type_to_klass, "ecf_reduced")).to eql(Finance::Schedule::ECF)
      expect(subject.send(:type_to_klass, "ecf_extended")).to eql(Finance::Schedule::ECF)
      expect(subject.send(:type_to_klass, "ecf_replacement")).to eql(Finance::Schedule::Mentor)
    end
  end
end
