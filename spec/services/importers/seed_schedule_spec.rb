# frozen_string_literal: true

require "tempfile"

RSpec.describe Importers::SeedSchedule do
  describe "#call" do
    context "when a schedule changes name" do
      let(:cohort) { Cohort[2021] || create(:cohort, start_year: 2021) }
      let(:csv) { Tempfile.new("data.csv") }
      let(:path_to_csv) { csv.path }

      subject do
        described_class.new(path_to_csv:, klass: Finance::Schedule::ECF)
      end

      let!(:schedule) { create(:schedule, name: "foo extra", schedule_identifier: "foo", cohort:) }

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
  end
end
