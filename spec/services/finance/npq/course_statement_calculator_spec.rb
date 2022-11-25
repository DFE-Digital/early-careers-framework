# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::NPQ::CourseStatementCalculator, :with_default_schedules, with_feature_flags: { multiple_cohorts: "active" } do
  let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:npq_leadership_schedule) { create(:npq_leadership_schedule, cohort:) }
  let!(:npq_specialist_schedule) { create(:npq_specialist_schedule, cohort:) }

  let(:npq_course)          { create(:npq_course) }
  let(:schedule)            { NPQCourse.schedule_for(npq_course:, cohort:) }
  let(:statement)           { create(:npq_statement, :next_output_fee, deadline_date: schedule.milestones.find_by(declaration_type: "completed").start_date + 30.days, cohort:) }
  let(:cpd_lead_provider)   { statement.cpd_lead_provider }
  let(:npq_lead_provider)   { cpd_lead_provider.npq_lead_provider }
  let(:participant_profile) { create(:npq_application, :accepted, :eligible_for_funding, npq_course:, npq_lead_provider:).profile }
  let!(:contract)           { create(:npq_contract, npq_lead_provider:, course_identifier: npq_course.identifier, cohort:) }
  subject { described_class.new(statement:, contract:) }

  describe "#billable_declarations_count_for_declaration_type" do
    before do
      travel_to statement.deadline_date do
        create_list(:npq_participant_declaration, 6, :eligible, npq_course:, declaration_type: %w[started retained-1 retained-2 completed].sample, cpd_lead_provider:)
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
          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:)
        end
      end

      it "is counted" do
        expect(subject.billable_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of one type" do
      let(:participant_declaration) { create(:npq_participant_declaration, :eligible, participant_profile:, npq_course:, cpd_lead_provider:) }

      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:).tap do |pd|
            pd.update!(user: participant_declaration.user)
          end
        end
      end

      it "is counted once" do
        expect(subject.billable_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of multiple types" do
      let(:started_participant_declaration)    { create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:) }
      let(:retained_1_participant_declaration) do
        create(:npq_participant_declaration,
               :eligible,
               participant_profile: started_participant_declaration.participant_profile,
               declaration_type: "retained-1",
               npq_course:,
               cpd_lead_provider:)
      end

      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:).tap do |pd|
            pd.update!(user: started_participant_declaration.user)
          end

          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:).tap do |pd|
            pd.update!(user: retained_1_participant_declaration.user)
          end
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
      let!(:to_be_awaiting_clawed_back) do
        travel_to create(:npq_statement, :next_output_fee, deadline_date: statement.deadline_date - 1.month, cpd_lead_provider:).deadline_date do
          create(:npq_participant_declaration, :paid, npq_course:, cpd_lead_provider:)
        end
      end
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
    let(:eligible_statement)                  { create(:npq_statement, :next_output_fee, deadline_date: statement.deadline_date - 1.month, cpd_lead_provider:) }
    let(:to_be_awaiting_claw_back_started)    { create(:npq_participant_declaration,         :eligible, npq_course:, cpd_lead_provider:) }
    let(:to_be_awaiting_claw_back_retained_1) { create_list(:npq_participant_declaration, 2, :eligible, declaration_type: "retained-1", npq_course:, cpd_lead_provider:) }
    let(:to_be_awaiting_claw_back_completed)  { create_list(:npq_participant_declaration, 3, :eligible, declaration_type: "retained-2", npq_course:, cpd_lead_provider:) }
    let(:declarations) do
      [to_be_awaiting_claw_back_started] + to_be_awaiting_claw_back_retained_1 + to_be_awaiting_claw_back_completed
    end
    before do
      travel_to(eligible_statement.deadline_date) do
        to_be_awaiting_claw_back_started
        to_be_awaiting_claw_back_retained_1
        to_be_awaiting_claw_back_completed
      end

      Statements::MarkAsPayable.new(eligible_statement).call
      Statements::MarkAsPaid.new(eligible_statement).call

      travel_to statement.deadline_date do
        declarations.each do |declaration|
          Finance::ClawbackDeclaration.new(declaration.reload).call
        end
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
          create(:npq_participant_declaration, :eligible, :voided, npq_course:, cpd_lead_provider:)
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
          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:)
        end
      end

      it do
        expect(subject.declaration_count_for_milestone(started_milestone)).to eql(1)
      end
    end

    context "when there are multiple declarations from same user and same type" do
      let(:participant_declaration) { create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:) }
      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:).tap do |pd|
            pd.update!(user: participant_declaration.user)
          end
        end
      end

      it "is counted once" do
        expect(subject.declaration_count_for_milestone(started_milestone)).to eql(1)
      end
    end
  end

  describe "#monthly_service_fees" do
    it "returns calculated service fee" do
      expect(subject.monthly_service_fees).to eql(BigDecimal("0.1212631578947368421052631578947368421064e4"))
    end

    context "when monthly_service_fee present on contract" do
      let(:contract) do
        create(
          :npq_contract,
          :with_monthly_service_fee,
          npq_lead_provider:,
          course_identifier: npq_course.identifier,
        )
      end

      it "returns monthly_service_fee from contract" do
        expect(subject.monthly_service_fees).to eql(5432.10)
      end
    end
  end

  describe "#service_fees_per_participant" do
    it "returns calculated service_fees_per_participant" do
      expect(subject.service_fees_per_participant).to eql(BigDecimal("0.16842105263157894736842105263157894737e2"))
    end

    context "when monthly_service_fee present on contract" do
      let(:contract) do
        create(
          :npq_contract,
          :with_monthly_service_fee,
          npq_lead_provider:,
          course_identifier: npq_course.identifier,
          recruitment_target: 438,
        )
      end

      it "returns value calulated from monthly_service_fee from contract" do
        expected = BigDecimal("0.12402054794520547945205479452054794521e2")

        expect(subject.service_fees_per_participant).to eql(expected)
      end
    end
  end

  describe "#course_has_targeted_delivery_funding?" do
    let(:cohort) { create(:cohort, start_year: 2022) }
    let(:statement) { create(:npq_statement) }

    context "Early headship coaching offer" do
      let!(:npq_course) { create(:npq_ehco_course) }

      it do
        expect(subject.course_has_targeted_delivery_funding?).to be false
      end
    end

    context "Additional support offer" do
      let!(:npq_course) { create(:npq_aso_course) }

      it do
        expect(subject.course_has_targeted_delivery_funding?).to be false
      end
    end

    context "Leadership course" do
      let!(:npq_course) { create(:npq_leadership_course) }

      it do
        expect(subject.course_has_targeted_delivery_funding?).to be true
      end
    end
  end

  describe "#targeted_delivery_funding_declarations_count" do
    let(:cohort) { create(:cohort, start_year: 2022) }

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

    context "when there are zero declarations" do
      it do
        expect(subject.targeted_delivery_funding_declarations_count).to be_zero
      end
    end

    context "when there are targeted delivery funding declarations" do
      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, :eligible, npq_course:, cpd_lead_provider:, participant_profile:)
        end
      end

      it "is counted" do
        expect(subject.targeted_delivery_funding_declarations_count).to eql(1)
      end
    end

    context "when multiple declarations from same user of one type" do
      let(:participant_profile) do
        create(
          :npq_application,
          :accepted,
          :eligible_for_funding,
          :with_started_declaration,
          npq_course:,
          npq_lead_provider:,
          eligible_for_funding: true,
          targeted_delivery_funding_eligibility: true,
        ).profile
      end

      before do
        travel_to statement.deadline_date do
          create(:npq_participant_declaration, npq_course:, cpd_lead_provider:, participant_profile:, declaration_type: "retained-1", course_identifier: npq_course.identifier)
        end
      end

      it "has two declarations" do
        expect(ParticipantDeclaration.count).to eql(2)
        expect(subject.statement.statement_line_items.count).to eql(2)
      end

      it "has one targeted delivery funding declaration" do
        expect(subject.targeted_delivery_funding_declarations_count).to eql(1)
      end
    end
  end

  describe "#targeted_delivery_funding_refundable_declarations_count" do
    let(:cohort) { create(:cohort, start_year: 2022) }

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

    context "when there are zero declarations" do
      it do
        expect(subject.targeted_delivery_funding_refundable_declarations_count).to be_zero
      end
    end

    context "when there are targeted delivery funding refundable declarations" do
      let!(:to_be_awaiting_clawed_back) do
        travel_to create(:npq_statement, :next_output_fee, deadline_date: statement.deadline_date - 1.month, cpd_lead_provider:).deadline_date do
          create(:npq_participant_declaration, :paid, npq_course:, cpd_lead_provider:, participant_profile:)
        end
      end

      before do
        travel_to statement.deadline_date do
          Finance::ClawbackDeclaration.new(to_be_awaiting_clawed_back).call
        end
      end

      it "has one targeted delivery funding refundable declaration" do
        expect(subject.targeted_delivery_funding_refundable_declarations_count).to eql(1)
      end
    end
  end
end
