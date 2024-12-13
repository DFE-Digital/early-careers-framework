# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::StatementCalculator, mid_cohort: true do
  let(:cohort)              { Cohort.current || create(:cohort, :current) }
  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider)   { cpd_lead_provider.npq_lead_provider }
  let(:statement)           { create(:npq_statement, cpd_lead_provider:) }
  let(:participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let(:milestone)           { participant_profile.schedule.milestones.find_by!(declaration_type:) }
  let(:declaration_type)    { "started" }

  let!(:npq_leadership_schedule) { create(:npq_leadership_schedule, cohort:) }
  let!(:npq_specialist_schedule) { create(:npq_specialist_schedule, cohort:) }
  let!(:npq_course)              { create(:npq_leadership_course, identifier: "npq-leading-teaching") }

  subject { described_class.new(statement:) }

  describe "#total_payment" do
    let!(:contract) { create(:npq_contract, npq_lead_provider:, cohort:, monthly_service_fee: nil) }
    let(:default_total) { BigDecimal("0.1212631578947368421052631578947368421064e4") }

    context "when there is a positive reconcile_amount" do
      before { statement.update!(reconcile_amount: 1234) }

      it "increases total" do
        expect(subject.total_payment).to eq(default_total + 1234)
      end
    end

    context "when there is a negative reconcile_amount" do
      before { statement.update!(reconcile_amount: -1234) }

      it "descreases the total" do
        expect(subject.total_payment).to eq(default_total - 1234)
      end
    end
  end

  describe "#total_starts" do
    context "when there are no declarations" do
      it { expect(subject.total_starts).to be_zero }
    end

    context "when there are declarations" do
      let!(:participant_declaration) do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, cpd_lead_provider:, participant_profile:)
        end
      end

      context "with a billable declaration" do
        it "counts them" do
          expect(subject.total_starts).to eq(1)
        end
      end
    end
  end

  describe "#total_completed" do
    let(:declaration_type) { "completed" }

    context "when there are no declarations" do
      it do
        expect(subject.total_completed).to be_zero
      end
    end

    context "when there are declarations" do
      let(:statement) { participant_declaration.statement_line_items.eligible.first.statement }

      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :eligible, declaration_type:, cpd_lead_provider:, participant_profile:)
        end
      end

      it "counts them" do
        expect(subject.total_completed).to eq(1)
      end
    end
  end

  describe "#total_retained" do
    let(:declaration_type) { "retained-1" }

    context "when there are no declarations" do
      it do
        expect(subject.total_retained).to be_zero
      end
    end

    context "when there are declarations" do
      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :eligible, course_identifier: npq_course.identifier, declaration_type: "retained-1", participant_profile:, cpd_lead_provider:)
        end
      end
      let(:statement) { participant_declaration.statement_line_items.eligible.first.statement }

      it "counts them" do
        expect(subject.total_retained).to eq(1)
      end
    end
  end

  describe "#total_voided" do
    context "when there are no declarations" do
      it { expect(subject.total_voided).to be_zero }
    end

    context "when there are declarations" do
      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :voided, participant_profile:, cpd_lead_provider:)
        end
      end
      let(:statement) { participant_declaration.statement_line_items.voided.first.statement }

      it "counts them" do
        expect(subject.total_voided).to eq(1)
      end
    end
  end

  context "when there exists contracts over multiple cohorts" do
    let!(:cohort_2022) { Cohort.next || create(:cohort, :next) }
    let!(:contract_2022) { create(:npq_contract, npq_lead_provider:, cohort: cohort_2022) }
    let!(:statement_2022) { create(:npq_statement, cpd_lead_provider:, cohort: cohort_2022) }

    before do
      declaration = create(
        :npq_participant_declaration,
        state: "eligible",
        course_identifier: npq_course.identifier,
        npq_course:,
      )

      Finance::StatementLineItem.create!(
        statement: statement_2022,
        participant_declaration: declaration,
        state: declaration.state,
      )
    end

    it "only includes declarations for the related cohort" do
      expect(described_class.new(statement:).total_starts).to be_zero
      expect(described_class.new(statement: statement_2022).total_starts).to eql(1)
    end
  end

  describe "#total_targeted_delivery_funding" do
    context "no declarations" do
      it do
        expect(subject.total_targeted_delivery_funding).to be_zero
      end
    end

    context "with declaration" do
      let(:declaration_type) { "started" }

      let(:participant_profile) do
        create(
          :npq_application,
          :accepted,
          :eligible_for_funding,
          npq_course:,
          npq_lead_provider:,

          eligible_for_funding: true,
          targeted_delivery_funding_eligibility: true,
        ).profile
      end

      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :eligible, course_identifier: npq_course.identifier, declaration_type:, participant_profile:, cpd_lead_provider:)
        end
      end

      let(:statement) { participant_declaration.statement_line_items.eligible.first.statement }

      it "returns total targeted delivery funding" do
        expect(subject.total_targeted_delivery_funding.to_f).to eq(100.0)
      end
    end
  end

  describe "NPQContract with special_course" do
    let!(:npq_maths_course) { create(:npq_leadership_course, identifier: "npq-leading-primary-mathematics") }

    let(:leading_maths_contract) do
      npq_lead_provider.npq_contracts.find_by(
        version: statement.contract_version,
        cohort: statement.cohort,
        course_identifier: npq_maths_course.identifier,
      )
    end

    before do
      travel_to statement.deadline_date do
        create_list(:npq_participant_declaration, 3, :eligible, npq_course:, cpd_lead_provider:)
        create_list(:npq_participant_declaration, 7, :eligible, npq_course: npq_maths_course, cpd_lead_provider:)
      end
    end

    context "when leading_maths_contract has special_course is false" do
      it "totals all course types" do
        expect(NPQContract.count).to eql(2)
        expect(subject.total_output_payment.to_f).to eq(160.0 * 10)
        expect(subject.total_starts.to_f).to eq(10)
      end
    end

    context "when leading_maths_contract has special_course is true" do
      before do
        leading_maths_contract.update!(special_course: true)
      end

      it "totals only totals course types that are not special" do
        expect(NPQContract.count).to eql(2)
        expect(subject.total_output_payment.to_f).to eq(160.0 * 3)
        expect(subject.total_starts.to_f).to eq(3)
      end
    end
  end
end
