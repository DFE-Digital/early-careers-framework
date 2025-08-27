# frozen_string_literal: true

describe Oneoffs::UpdateStatements do
  let(:cohort) { create(:cohort, start_year: 2025) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:statement_with_no_updates) { create(:ecf_statement, cohort:, name: "July 2025", deadline_date: Date.new(2025, 6, 30), payment_date: Date.new(2025, 7, 28), cpd_lead_provider:, output_fee: false) }

  let(:other_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:statement_with_updates) { create(:ecf_statement, cohort:, name: "August 2025", deadline_date: Date.new(2025, 7, 29), payment_date: Date.new(2025, 8, 28), cpd_lead_provider: other_cpd_lead_provider, output_fee: false) }

  let(:csv_content) do
    <<~CSV
      type,name,cohort,deadline_date,payment_date,output_fee
      ecf,July 2025,2025,2025-06-30,2025-07-28,false
      ecf,August 2025,2025,2025-07-31,2025-08-29,true
    CSV
  end

  let(:instance) { described_class.new(path_to_csv:) }
  subject(:perform_change) { instance.perform_change(dry_run:) }

  let(:csv) { Tempfile.new("statements.csv") }
  let(:path_to_csv) { csv.path }
  before do
    allow(Rails.logger).to receive(:info)

    csv.write(csv_content)
    csv.rewind
  end

  after do
    csv.close
    csv.unlink
  end

  describe "#perform_change" do
    let(:dry_run) { false }

    it { is_expected.to eq(instance.recorded_info) }

    it "updates the statement with different values to csv" do
      expect { perform_change }.to change { statement_with_updates.reload.deadline_date }.to(Date.new(2025, 7, 31))
      .and change { statement_with_updates.reload.payment_date }.to(Date.new(2025, 8, 29))
      .and change { statement_with_updates.reload.output_fee }.to(true)
    end

    it "does not update statement with equal values to csv" do
      expect { perform_change }.not_to change { statement_with_no_updates.reload.attributes }
    end

    it "logs out information" do
      perform_change
      expect(instance).to have_recorded_info([
        "Looking at statements for cohort: 2025 and name: July 2025",
        "No updates made to statement: '#{statement_with_no_updates.id}' with cohort: 2025 and name: July 2025",
        "Looking at statements for cohort: 2025 and name: August 2025",
        "Updating statement: '#{statement_with_updates.id}' with changes: {\"deadline_date\"=>[Tue, 29 Jul 2025, Thu, 31 Jul 2025], \"payment_date\"=>[Thu, 28 Aug 2025, Fri, 29 Aug 2025], \"output_fee\"=>[false, true]}",
      ])
    end

    it "does not change statements that belong to other cohorts" do
      other_cohort = create(:cohort, start_year: 2023)
      statement_other_cohort = create(:ecf_statement, cohort: other_cohort, cpd_lead_provider:)

      expect { perform_change }.not_to change { statement_other_cohort.reload.attributes }
    end

    context "when statements in csv do not exist" do
      let(:csv_content) do
        <<~CSV
          type,name,cohort,deadline_date,payment_date,output_fee
          ecf,July 2028,2025,2025-06-30,2025-07-28,false
        CSV
      end

      it "does not change statements" do
        expect { perform_change }.not_to change { Finance::Statement::ECF.all.reload.pluck(:deadline_date, :payment_date, :output_fee) }
      end

      it "logs out information" do
        perform_change
        expect(instance).to have_recorded_info([
          "Looking at statements for cohort: 2025 and name: July 2028",
          "No statements found for cohort: 2025 with name: July 2028",
        ])
      end
    end

    context "when headers are invalid" do
      let(:csv_content) do
        <<~CSV
          invalid-header-name,type,name,cohort,deadline_date,payment_date
        CSV
      end

      it "raises a NameError" do
        expect { perform_change }.to raise_error(NameError, "Invalid CSV headers")
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not make any changes, but records the changes it would make" do
        expect { perform_change }.not_to change { statement_with_updates.reload.attributes }

        expect(instance).to have_recorded_info([
          "~~~ DRY RUN ~~~",
          "Looking at statements for cohort: 2025 and name: July 2025",
          "No updates made to statement: '#{statement_with_no_updates.id}' with cohort: 2025 and name: July 2025",
          "Looking at statements for cohort: 2025 and name: August 2025",
          "Updating statement: '#{statement_with_updates.id}' with changes: {\"deadline_date\"=>[Tue, 29 Jul 2025, Thu, 31 Jul 2025], \"payment_date\"=>[Thu, 28 Aug 2025, Fri, 29 Aug 2025], \"output_fee\"=>[false, true]}",
        ])
      end
    end
  end
end
