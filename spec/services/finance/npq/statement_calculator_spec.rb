# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::StatementCalculator, :with_default_schedules, with_feature_flags: { multiple_cohorts: "active" } do
  let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:npq_leadership_schedule) { create(:npq_leadership_schedule, cohort:) }
  let!(:npq_specialist_schedule) { create(:npq_specialist_schedule, cohort:) }

  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider)   { cpd_lead_provider.npq_lead_provider }
  let!(:npq_course)         { create(:npq_leadership_course, identifier: "npq-leading-teaching") }
  let(:statement)           { create(:npq_statement, cpd_lead_provider:) }
  let(:participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let(:milestone)           { participant_profile.schedule.milestones.find_by!(declaration_type:) }
  let(:declaration_type)    { "started" }
  let!(:contract) { create(:npq_contract, npq_lead_provider:, cohort:) }

  subject { described_class.new(statement:) }

  describe "#total_payment" do
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

    context "when there are clawbacks" do
      let!(:participant_declaration) do
        travel_to(1.month.ago) { create(:npq_participant_declaration, :paid, cpd_lead_provider:) }
      end
      let(:paid_statement)     { Finance::Statement::NPQ::Paid.find_by!(cpd_lead_provider:) }
      let!(:statement)         { create(:npq_statement, :next_output_fee, deadline_date: paid_statement.deadline_date + 1.month, cpd_lead_provider:) }

      before do
        travel_to statement.deadline_date do
          Finance::ClawbackDeclaration.new(participant_declaration).call
        end
      end

      it "does not count them" do
        expect(statement.reload.statement_line_items.awaiting_clawback).to exist
        expect(subject.total_starts).to be_zero
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
      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :eligible, declaration_type:, cpd_lead_provider:, participant_profile:)
        end
      end
      let(:statement) { participant_declaration.statement_line_items.eligible.first.statement }

      it "counts them" do
        expect(subject.total_completed).to eq(1)
      end
    end

    context "when there are clawbacks" do
      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :paid, declaration_type:, cpd_lead_provider:, participant_profile:)
        end
      end
      let(:previous_statement) { participant_declaration.statements.first }
      let!(:statement)         { create(:npq_statement, :next_output_fee, deadline_date: previous_statement.deadline_date + 1.month, cpd_lead_provider:) }
      before do
        travel_to statement.deadline_date do
          Finance::ClawbackDeclaration.new(participant_declaration).call
        end
      end

      it "does not count them" do
        expect(statement.statement_line_items.awaiting_clawback).to exist
        expect(subject.total_completed).to be_zero
      end
    end
  end

  describe "#overall_vat" do
    let(:default_total) { BigDecimal("0.1212631578947368421052631578947368421064e4") }

    context "when reconcile_amount is present and VAT is applicable" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "affects the amount to reconcile by" do
        expect(subject.overall_vat).to eq((default_total + 1234) * 0.2)
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

    context "when there are clawbacks" do
      let!(:participant_declaration) do
        travel_to milestone.start_date do
          create(:npq_participant_declaration, :paid, declaration_type: "retained-1", cpd_lead_provider:, participant_profile:)
        end
      end
      let(:previous_statement) { participant_declaration.statements.first }
      let!(:statement)         { create(:npq_statement, :next_output_fee, deadline_date: previous_statement.deadline_date + 1.month, cpd_lead_provider:) }
      before do
        travel_to statement.deadline_date do
          Finance::ClawbackDeclaration.new(participant_declaration).call
        end
      end

      it "does not count them" do
        expect(subject.total_retained).to be_zero
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

  context "when there exists contracts over multiple cohorts", with_feature_flags: { multiple_cohorts: "active" } do
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
      let(:cohort) { create(:cohort, start_year: 2022) }
      let(:declaration_type)    { "started" }

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

  describe "#total_targeted_delivery_funding_refundable" do
    context "no declarations" do
      it do
        expect(subject.total_targeted_delivery_funding_refundable).to be_zero
      end
    end

    context "with declaration" do
      let(:cohort) { create(:cohort, start_year: 2022) }
      let(:declaration_type)    { "started" }

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

      let!(:to_be_awaiting_clawed_back) do
        travel_to create(:npq_statement, :next_output_fee, deadline_date: statement.deadline_date - 1.month, cpd_lead_provider:).deadline_date do
          create(:npq_participant_declaration, :paid, course_identifier: npq_course.identifier, declaration_type:, participant_profile:, cpd_lead_provider:)
        end
      end

      let!(:participant_declaration) do
        travel_to statement.deadline_date do
          Finance::ClawbackDeclaration.new(to_be_awaiting_clawed_back).call
        end
      end

      it "returns total targeted delivery funding refundable" do
        expect(subject.total_targeted_delivery_funding_refundable.to_f).to eq(100.0)
      end
    end
  end

  describe "#total_clawbacks" do
    let(:cohort) { create(:cohort, start_year: 2022) }
    let(:declaration_type)    { "started" }

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

    let!(:to_be_awaiting_clawed_back) do
      travel_to create(:npq_statement, :next_output_fee, deadline_date: statement.deadline_date - 1.month, cpd_lead_provider:).deadline_date do
        create(:npq_participant_declaration, :paid, course_identifier: npq_course.identifier, declaration_type:, participant_profile:, cpd_lead_provider:)
      end
    end

    let!(:participant_declaration) do
      travel_to statement.deadline_date do
        Finance::ClawbackDeclaration.new(to_be_awaiting_clawed_back).call
      end
    end

    it "returns total clawbacks" do
      expect(subject.clawback_payments.to_f).to eq(160.0)
      expect(subject.total_targeted_delivery_funding_refundable.to_f).to eq(100.0)
      expect(subject.total_clawbacks.to_f).to eq(160.0 + 100.0)
    end
  end
end
