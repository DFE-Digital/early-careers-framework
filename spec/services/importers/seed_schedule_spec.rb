# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::SeedSchedule do
  describe "#call" do
    subject do
      Importers::SeedSchedule.new(
        path_to_csv: Rails.root.join("db/seeds/schedules/ecf_standard.csv"),
        klass: Finance::Schedule::ECF,
      )
    end

    context "when a schedule changes name" do
      subject do
        described_class.new(path_to_csv: path_to_csv, klass: Finance::Schedule::ECF)
      end

      let(:csv) { Tempfile.new("data.csv") }
      let(:path_to_csv) { csv.path }
      let!(:schedule) { create(:schedule, name: "foo extra", schedule_identifier: "foo") }

      before do
        csv.write "schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
        csv.write "\n"
        csv.write "foo,just foo,2021,Output 1 - Participant Start,started,2021/09/01,2021/11/30,2021/11/30"
        csv.close
      end

      it "does not create a new schedule" do
        expect {
          subject.call
        }.not_to change(Finance::Schedule, :count)
      end

      it "updates the name of the existing schedule" do
        expect {
          subject.call
        }.to change { schedule.reload.name }.from("foo extra").to("just foo")
      end
    end

    it "is idempotent" do
      subject.call
      subject.call

      expect(Finance::Schedule.find_by(name: "ECF Standard April").milestones.count).to eq(6)
    end
  end
end
