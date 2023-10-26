# frozen_string_literal: true

RSpec.describe Oneoffs::NPQ::SetSpecialCourseForNPQContracts do
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:payment_date_range) { Date.new(2023, 10, 1)..Date.new(2023, 11, 30) }
  let(:course_identifier) { create(:npq_course, identifier: "npq-leading-primary-mathematics").identifier }

  subject { described_class.new(cohort_year: cohort.start_year, payment_date_range:, course_identifier:) }

  describe "#call" do
    let!(:npq_statement1) { create(:npq_statement, cohort:, contract_version: "0.0.1", payment_date: "2023-10-25") }
    let!(:npq_contract1) do
      create(
        :npq_contract,
        course_identifier:,
        npq_lead_provider: npq_statement1.npq_lead_provider,
        cohort: npq_statement1.cohort,
        version: npq_statement1.contract_version,
        special_course: false,
      )
    end

    let!(:npq_statement2) { create(:npq_statement, cohort:, contract_version: "0.0.4", payment_date: "2023-11-25") }
    let!(:npq_contract2) do
      create(
        :npq_contract,
        course_identifier:,
        npq_lead_provider: npq_statement2.npq_lead_provider,
        cohort: npq_statement2.cohort,
        version: npq_statement2.contract_version,
        special_course: true,
      )
    end

    let!(:npq_statement3) { create(:npq_statement, cohort:, contract_version: "0.0.7", payment_date: "2023-09-25") }
    let!(:npq_contract3) do
      create(
        :npq_contract,
        course_identifier:,
        npq_lead_provider: npq_statement3.npq_lead_provider,
        cohort: npq_statement3.cohort,
        version: npq_statement3.contract_version,
        special_course: false,
      )
    end

    it "should create new contract for npq_statement1 with special_course=true" do
      expect(Finance::Statement::NPQ.count).to eql(3)
      expect(npq_statement1.reload.contract_version).to eql("0.0.1")
      expect(npq_statement2.reload.contract_version).to eql("0.0.4")
      expect(npq_statement3.reload.contract_version).to eql("0.0.7")

      expect(NPQContract.count).to eql(3)
      expect(NPQContract.where(special_course: false).count).to eql(2)
      expect(NPQContract.where(special_course: true).count).to eql(1)

      subject.call

      expect(Finance::Statement::NPQ.count).to eql(3)
      expect(npq_statement1.reload.contract_version).to eql("0.0.2")
      expect(npq_statement2.reload.contract_version).to eql("0.0.4")
      expect(npq_statement3.reload.contract_version).to eql("0.0.7")

      expect(NPQContract.count).to eql(3 + 1)
      expect(NPQContract.where(special_course: false).count).to eql(2)
      expect(NPQContract.where(special_course: true).count).to eql(2)
    end

    it "should create new contract matching old contract" do
      # Run twice to check for duplicates
      subject.call
      subject.call
      expect(NPQContract.count).to eql(3 + 1)

      old_npq_contract1 = NPQContract.where(
        cohort: npq_contract1.cohort,
        npq_lead_provider: npq_contract1.npq_lead_provider,
        version: "0.0.1",
      ).first
      new_npq_contract1 = NPQContract.where(
        cohort: npq_contract1.cohort,
        npq_lead_provider: npq_contract1.npq_lead_provider,
        version: "0.0.2",
      ).first

      expect(new_npq_contract1.recruitment_target).to eql(old_npq_contract1.recruitment_target)
      expect(new_npq_contract1.course_identifier).to eql(old_npq_contract1.course_identifier)
      expect(new_npq_contract1.service_fee_installments).to eql(old_npq_contract1.service_fee_installments)
      expect(new_npq_contract1.service_fee_percentage).to eql(old_npq_contract1.service_fee_percentage)
      expect(new_npq_contract1.per_participant).to eql(old_npq_contract1.per_participant)
      expect(new_npq_contract1.number_of_payment_periods).to eql(old_npq_contract1.number_of_payment_periods)
      expect(new_npq_contract1.output_payment_percentage).to eql(old_npq_contract1.output_payment_percentage)
      expect(new_npq_contract1.monthly_service_fee).to eql(old_npq_contract1.monthly_service_fee)
      expect(new_npq_contract1.targeted_delivery_funding_per_participant).to eql(old_npq_contract1.targeted_delivery_funding_per_participant)
      expect(new_npq_contract1.special_course).to eql(true)
    end
  end
end
