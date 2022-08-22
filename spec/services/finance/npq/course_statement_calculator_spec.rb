# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::CourseStatementCalculator, :with_default_schedules do
  let(:statement)           { create(:npq_statement) }
  let(:cpd_lead_provider)   { statement.cpd_lead_provider }
  let(:npq_lead_provider)   { cpd_lead_provider.npq_lead_provider }
  let(:npq_course)          { create(:npq_course) }
  let(:participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let!(:contract)           { create(:npq_contract, npq_lead_provider:, course_identifier: npq_course.identifier) }

  subject { described_class.new(statement:, contract:) }

  describe "#billable_declarations_count_for_declaration_type" do
    before do
      travel_to statement.deadline_date do
        create_list(
          :npq_participant_declaration,
          6,
          :eligible,
          course_identifier: npq_course.identifier,
          declaration_type: %w[started retained-1 retained-2 completed].sample,
          cpd_lead_provider:,
        )
      end
    end

    it "can count different declaration types", :aggregate_failures do
      expect(subject.billable_declarations_count_for_declaration_type("started")).to eql(ParticipantDeclaration::NPQ.where(declaration_type: "started").count)
      expect(subject.billable_declarations_count_for_declaration_type("retained")).to eql(ParticipantDeclaration::NPQ.where(declaration_type: %w[retained-1 retained-2]).count)
      expect(subject.billable_declarations_count_for_declaration_type("completed")).to eql(ParticipantDeclaration::NPQ.where(declaration_type: "completed").count)
    end
  end

  describe "#billable_declarations_count" do
    context "when there are zero declarations" do
      it do
        expect(subject.billable_declarations_count).to be_zero
      end
    end

    context "when there are billable declarations" do
      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, course_identifier: npq_course.identifier, cpd_lead_provider:)
        end
      end

      it "is counted" do
        expect(subject.billable_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of one type" do
      let(:participant_profile) do
        create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile
      end
      before do
        travel_to statement.deadline_date do
          create_list(:npq_participant_declaration, 2, :eligible, participant_profile:, course_identifier: npq_course.identifier, cpd_lead_provider:)
        end
      end

      it "is counted once" do
        expect(subject.billable_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of multiple types" do
      let(:participant_profile) do
        create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile
      end

      before do
        travel_to statement.deadline_date do
          create_list(
            :npq_participant_declaration, 2,
            :eligible,
            participant_profile:,
            course_identifier: npq_course.identifier,
            declaration_type: "started",
            cpd_lead_provider:
          )
          create_list(
            :npq_participant_declaration, 2,
            :eligible,
            participant_profile:,
            course_identifier: npq_course.identifier,
            declaration_type: "retained-1",
            cpd_lead_provider:
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
      let!(:to_be_awaiting_clawed_back) { create(:npq_participant_declaration, :paid, course_identifier: npq_course.identifier, cpd_lead_provider:) }
      before do
        travel_to statement.deadline_date do
          Finance::ClawbackDeclaration.new(to_be_awaiting_clawed_back).call
        end
      end

      it "is counted" do
        expect(subject.refundable_declarations_count).to eql(1)
      end
    end
  end

  describe "#refundable_declarations_by_type_count" do
    let!(:to_be_awaiting_claw_back_started)    { create(:npq_participant_declaration, :paid, declaration_type: "started", course_identifier: npq_course.identifier, cpd_lead_provider:) }
    let!(:to_be_awaiting_claw_back_retained_1) { create_list(:npq_participant_declaration, 2, :paid, declaration_type: "retained-1", course_identifier: npq_course.identifier, cpd_lead_provider:) }
    let!(:to_be_awaiting_claw_back_completed)  { create_list(:npq_participant_declaration, 3, :paid, declaration_type: "retained-2", course_identifier: npq_course.identifier, cpd_lead_provider:) }
    before do
      travel_to statement.deadline_date do
        ([to_be_awaiting_claw_back_started] + to_be_awaiting_claw_back_retained_1 + to_be_awaiting_claw_back_completed).each { |declaration|Finance::ClawbackDeclaration.new(declaration).call}
      end
    end

    it "returns counts of refunds by type" do
      expected = {
        "started" => 1,
        "retained-1" => 2,
        "retained-2" => 3,
      }

      expect(subject.refundable_declarations_by_type_count).to eql(expected)
    end
  end

  describe "#not_eligible_declarations" do
    context "when there are voided declarations" do
      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, :voided, course_identifier: npq_course.identifier, cpd_lead_provider:)
        end
      end

      it "is counted" do
        expect(subject.not_eligible_declarations_count).to eql(1)
      end
    end
  end

  describe "#declaration_count_for_milestone" do
    let(:started_milestone) { NPQCourse.schedule_for(npq_course:).milestones.find_by(declaration_type: "started") }

    context "when there are no declarations" do
      it do
        expect(subject.declaration_count_for_milestone(started_milestone)).to be_zero
      end
    end

    context "when there are declarations" do
      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, course_identifier: npq_course.identifier, cpd_lead_provider:)
        end
      end

      it do
        expect(subject.declaration_count_for_milestone(started_milestone)).to eql(1)
      end
    end

    context "when there are multiple declarations from same user and same type" do
      before do
        travel_to statement.deadline_date do
          create_list(:npq_participant_declaration, 2, :eligible, participant_profile:, course_identifier: npq_course.identifier, cpd_lead_provider:)
        end
      end

      it "is counted once" do
        expect(subject.declaration_count_for_milestone(started_milestone)).to eql(1)
      end
    end
  end
end
