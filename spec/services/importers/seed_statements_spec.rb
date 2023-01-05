# frozen_string_literal: true

RSpec.describe Importers::SeedStatements do
  let!(:cpd_lead_provider) do
    create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider)
  end

  let!(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:cohort_2022) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }

  describe "#call" do
    it "creates ECF statements idempotently" do
      expect {
        subject.call
        subject.call
      }.to change(Finance::Statement::ECF, :count).by(60)
    end

    it "creates NPQ statements idempotently" do
      expect {
        subject.call
        subject.call
      }.to change(Finance::Statement::NPQ, :count).by(72)
    end

    it "populates statements correctly" do
      subject.call

      expect(
        Finance::Statement::ECF.find_by(
          name: "November 2022",
          cohort: cohort_2021,
          deadline_date: Date.new(2022, 10, 31),
          payment_date: Date.new(2022, 11, 25),
          contract_version: "0.0.1",
          output_fee: false,
        ),
      ).to be_present

      expect(
        Finance::Statement::ECF.find_by(
          name: "November 2022",
          cohort: cohort_2022,
          deadline_date: Date.new(2022, 11, 30),
          payment_date: Date.new(2022, 11, 30),
          contract_version: "0.0.1",
          output_fee: true,
        ),
      ).to be_present

      expect(
        Finance::Statement::NPQ.find_by(
          name: "January 2023",
          cohort: cohort_2021,
          deadline_date: Date.new(2022, 12, 25),
          payment_date: Date.new(2023, 1, 25),
          contract_version: "0.0.1",
          output_fee: true,
        ),
      ).to be_present

      expect(
        Finance::Statement::NPQ.find_by(
          name: "January 2023",
          cohort: cohort_2022,
          deadline_date: Date.new(2022, 12, 25),
          payment_date: Date.new(2023, 1, 25),
          contract_version: "0.0.1",
          output_fee: true,
        ),
      ).to be_present
    end
  end
end
