# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQContract do
  it { is_expected.to belong_to(:cohort) }

  describe "associations" do
    it { is_expected.to belong_to(:npq_lead_provider) }
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:npq_course).with_primary_key("identifier").with_foreign_key("course_identifier") }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:number_of_payment_periods).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:output_payment_percentage).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:service_fee_installments).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:service_fee_percentage).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:per_participant).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:recruitment_target).is_greater_than(0).only_integer }
    it { is_expected.to validate_numericality_of(:funding_cap).is_greater_than_or_equal_to(0).only_integer.allow_nil }
  end

  describe ".find_latest_by" do
    let(:cohort) { create(:cohort) }
    let(:npq_application) { create(:npq_application, eligible_for_funding: true, npq_course:, npq_lead_provider:, cohort:) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
    let(:statement) do
      create(
        :npq_statement,
        :next_output_fee,
        cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
        cohort: npq_application.cohort,
      )
    end

    before do
      create(:npq_contract,
             npq_lead_provider:,
             cohort: statement.cohort,
             course_identifier: npq_course.identifier,
             version: statement.contract_version,
             funding_cap: 10)
    end

    it "returns the latest NPQContract" do
      contract = described_class.find_latest_by(
        npq_lead_provider:,
        npq_course:,
        cohort:,
      )

      expect(contract).to eq(npq_contract)
    end

    context "when cohort is different" do
      it "returns `nil` if cohort is different" do
        contract = described_class.find_latest_by(
          npq_lead_provider:,
          npq_course:,
          cohort: create(:cohort),
        )

        expect(contract).to be_nil
      end
    end

    context "when npq_course is different" do
      it "returns `nil` if npq_course is different" do
        contract = described_class.find_latest_by(
          npq_lead_provider:,
          npq_course: create(:npq_leadership_course, identifier: "npq-headship"),
          cohort:,
        )

        expect(contract).to be_nil
      end
    end

    it "returns `nil` if npq_lead_provider is different" do
      contract = described_class.find_latest_by(
        npq_lead_provider: create(:npq_lead_provider),
        npq_course:,
        cohort:,
      )

      expect(contract).to be_nil
    end
  end
end
