# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::StatementCalculator do
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }

  let!(:npq_course) { create(:npq_leadship_course, identifier: "npq-leading-teaching") }

  let!(:contract) { create(:npq_contract, npq_lead_provider:) }

  let(:statement) { create(:npq_statement, cpd_lead_provider:) }

  subject { described_class.new(statement:) }

  describe "#total_payment" do
    let(:default_total) { BigDecimal("0.1212631578947368421052631578947368421064e4") }

    context "when there is a positive reconcile_amount" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "increases total" do
        expect(subject.total_payment).to eql(default_total + 1234)
      end
    end

    context "when there is a negative reconcile_amount" do
      before do
        statement.update!(reconcile_amount: -1234)
      end

      it "descreases the total" do
        expect(subject.total_payment).to eql(default_total - 1234)
      end
    end
  end

  describe "#total_starts" do
    context "when there are no declarations" do
      it do
        expect(subject.total_starts).to be_zero
      end
    end

    context "when there are declarations" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "eligible",
          course_identifier: npq_course.identifier
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "counts them" do
        expect(subject.total_starts).to eql(1)
      end
    end

    context "when there are clawbacks" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "awaiting_clawback",
          course_identifier: npq_course.identifier
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "does not count them" do
        expect(subject.total_starts).to be_zero
      end
    end
  end

  describe "#total_completed" do
    context "when there are no declarations" do
      it do
        expect(subject.total_completed).to be_zero
      end
    end

    context "when there are declarations" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "eligible",
          course_identifier: npq_course.identifier,
          declaration_type: "completed"
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "counts them" do
        expect(subject.total_completed).to eql(1)
      end
    end

    context "when there are clawbacks" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "awaiting_clawback",
          course_identifier: npq_course.identifier,
          declaration_type: "completed"
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "does not count them" do
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
        expect(subject.overall_vat).to eql((default_total + 1234) * 0.2)
      end
    end
  end

  describe "#total_retained" do
    context "when there are no declarations" do
      it do
        expect(subject.total_retained).to be_zero
      end
    end

    context "when there are declarations" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "eligible",
          course_identifier: npq_course.identifier,
          declaration_type: "retained-1"
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "counts them" do
        expect(subject.total_retained).to eql(1)
      end
    end

    context "when there are clawbacks" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "awaiting_clawback",
          course_identifier: npq_course.identifier,
          declaration_type: "retained-1"
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "does not count them" do
        expect(subject.total_retained).to be_zero
      end
    end
  end

  describe "#total_voided" do
    context "when there are no declarations" do
      it do
        expect(subject.total_voided).to be_zero
      end
    end

    context "when there are declarations" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "voided",
          course_identifier: npq_course.identifier
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "counts them" do
        expect(subject.total_voided).to eql(1)
      end
    end
  end
end
