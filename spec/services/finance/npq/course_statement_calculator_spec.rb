# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::CourseStatementCalculator do
  let(:cpd_lead_provider) { statement.cpd_lead_provider }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_course) { create(:npq_course) }

  let(:statement) { create(:npq_statement) }
  let!(:contract) { create(:npq_contract, npq_lead_provider:, course_identifier: npq_course.identifier) }

  subject { described_class.new(statement:, contract:) }

  describe "#billable_declarations_count" do
    context "when there are zero declarations" do
      it do
        expect(subject.billable_declarations_count).to be_zero
      end
    end

    context "when there are billable declarations" do
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

      it "is counted" do
        expect(subject.billable_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of one type" do
      let(:user) { create(:user, :npq) }

      before do
        declarations = create_list(
          :npq_participant_declaration, 2,
          user:,
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

      it "is counted once" do
        expect(subject.billable_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of multiple types" do
      let(:user) { create(:user, :npq) }

      before do
        declarations = create_list(
          :npq_participant_declaration, 2,
          user:,
          state: "eligible",
          course_identifier: npq_course.identifier,
          declaration_type: "started"
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end

        declarations = create_list(
          :npq_participant_declaration, 2,
          user:,
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

      it "counts each type once" do
        expect(subject.billable_declarations_count).to eql(2)
      end
    end
  end

  describe "#refundable_declarations_count" do
    context "when there are zero declarations" do
      it do
        expect(subject.refundable_declarations_count).to be_zero
      end
    end

    context "when there are refundable declarations" do
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

      it "is counted" do
        expect(subject.refundable_declarations_count).to eql(1)
      end
    end
  end

  describe "#not_eligible_declarations" do
    context "when there are ineligible or voided declarations" do
      before do
        declarations = create_list(
          :npq_participant_declaration, 1,
          state: "ineligible",
          course_identifier: npq_course.identifier
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end

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

      it "is counted" do
        expect(subject.not_eligible_declarations_count).to eql(2)
      end
    end
  end

  describe "#declaration_count_for_milestone" do
    let(:started_milestone) { build(:milestone, :started) }

    context "when there are no declarations" do
      it do
        expect(subject.declaration_count_for_milestone(started_milestone)).to be_zero
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

      it do
        expect(subject.declaration_count_for_milestone(started_milestone)).to eql(1)
      end
    end

    context "when there are multiple declarations from same user and same type" do
      let(:user) { create(:user, :npq) }

      before do
        declarations = create_list(
          :npq_participant_declaration, 2,
          state: "eligible",
          course_identifier: npq_course.identifier,
          user:
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "is counted once" do
        expect(subject.declaration_count_for_milestone(started_milestone)).to eql(1)
      end
    end
  end
end
