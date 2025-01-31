# frozen_string_literal: true

RSpec.describe Finance::ECF::Mentor::OutputCalculator, mid_cohort: true do
  let(:cohort) { Cohort.previous || create(:cohort, :previous) }

  let(:first_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 6.months.ago, cohort:) }
  let(:second_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 4.months.ago, cohort:) }
  let(:third_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 2.months.ago, cohort:) }
  let(:fourth_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 0.months.ago, cohort:) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:contract) { create(:mentor_call_off_contract, lead_provider:, cohort:) }

  let(:first_statement_calc) { described_class.new(statement: first_statement) }
  let(:second_statement_calc) { described_class.new(statement: second_statement) }
  let(:third_statement_calc) { described_class.new(statement: third_statement) }
  let(:fourth_statement_calc) { described_class.new(statement: fourth_statement) }

  let(:schedule) { Finance::Schedule.find_by(schedule_identifier: "ecf-standard-september", cohort:) }

  describe "#fee_for_declaration" do
    subject { first_statement_calc }

    it "returns correct fees" do
      expect(subject.fee_for_declaration(type: :started)).to eql(500)
      expect(subject.fee_for_declaration(type: :completed)).to eql(500)
    end
  end

  describe "#output_breakdown" do
    context "when no declarations" do
      it "returns empty counts" do
        expected = [
          {
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        expect(first_statement_calc.output_breakdown).to eql(expected)
      end
    end

    context "when some declarations" do
      let!(:to_be_paid_participant_declaration) do
        travel_to first_statement.deadline_date - 1.day do
          create_list(:mentor_participant_declaration, 5, :eligible, declaration_type: "started", cpd_lead_provider:, cohort:)
        end

        travel_to first_statement.deadline_date - 1.day do
          create_list(:mentor_participant_declaration, 3, :eligible, declaration_type: "completed", cpd_lead_provider:, cohort:)
        end
      end

      before do
        Statements::MarkAsPayable.new(first_statement).call
        Statements::MarkAsPaid.new(first_statement).call
      end

      it "returns correct counts" do
        expected = [
          {
            started_additions: 5,
            started_subtractions: 0,
          },
          {
            completed_additions: 3,
            completed_subtractions: 0,
          },
        ]

        expect(first_statement_calc.output_breakdown).to eql(expected)
      end
    end

    context "when clawbacks present" do
      before do
        declarations = create_list(
          :mentor_participant_declaration, 5,
          state: :paid,
          cohort:
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement: first_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end

        clawback_declarations = declarations.sample(2)

        clawback_declarations.each do |dec|
          dec.update!(state: "awaiting_clawback")

          Finance::StatementLineItem.create!(
            statement: second_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "can calculate refunds when current statement is empty" do
        first_statement_expectation = [
          {
            started_additions: 5,
            started_subtractions: 0,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        second_statement_expectation = [
          {
            started_additions: 0,
            started_subtractions: 2,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        expect(first_statement_calc.output_breakdown).to eql(first_statement_expectation)
        expect(second_statement_calc.output_breakdown).to eql(second_statement_expectation)
      end
    end

    context "when clawbacks present" do
      before do
        setup_statement_one
        setup_statement_two
        setup_statement_three
      end

      def setup_statement_one
        declarations = create_list(
          :mentor_participant_declaration, 3,
          state: :paid
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement: first_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      def setup_statement_two
        declarations = create_list(
          :mentor_participant_declaration, 3,
          state: :paid,
          cohort:
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement: second_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end

        clawback_line_items = first_statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { state: "paid" })
          .order(Arel.sql("RANDOM()")).limit(1)

        clawback_line_items.each do |line_item|
          Finance::StatementLineItem.create!(
            statement: second_statement,
            participant_declaration: line_item.participant_declaration,
            state: "clawed_back",
          )

          line_item.participant_declaration.update!(state: "clawed_back")
        end
      end

      def setup_statement_three
        declarations = create_list(
          :mentor_participant_declaration, 3,
          state: :payable,
          cohort:
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement: third_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end

        clawback_line_items = first_statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { state: "paid" })
          .order(Arel.sql("RANDOM()"))
          .limit(1)

        clawback_line_items.each do |line_item|
          Finance::StatementLineItem.create!(
            statement: third_statement,
            participant_declaration: line_item.participant_declaration,
            state: "awaiting_clawback",
          )

          line_item.participant_declaration.update!(state: "awaiting_clawback")
        end

        clawback_line_items = second_statement
          .billable_statement_line_items
          .order(Arel.sql("RANDOM()"))
          .joins(:participant_declaration)
          .where(participant_declarations: { state: "paid" })
          .limit(1)

        clawback_line_items.each do |line_item|
          Finance::StatementLineItem.create!(
            statement: third_statement,
            participant_declaration: line_item.participant_declaration,
            state: "awaiting_clawback",
          )

          line_item.participant_declaration.update!(state: "awaiting_clawback")
        end
      end

      it "can calculate refunds for typical use case" do
        first_statement_expectation = [
          {
            started_additions: 3,
            started_subtractions: 0,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        second_statement_expectation = [
          {
            started_additions: 3,
            started_subtractions: 1,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        third_statement_expectation = [
          {
            started_additions: 3,
            started_subtractions: 2,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        expect(first_statement_calc.output_breakdown).to eql(first_statement_expectation)
        expect(second_statement_calc.output_breakdown).to eql(second_statement_expectation)
        expect(third_statement_calc.output_breakdown).to eql(third_statement_expectation)
      end
    end

    context "when there is a clawback followed by a declaration again" do
      let(:participant_profile) { create(:mentor, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider, cohort:) }
      let!(:participant_declaration) do
        travel_to first_statement.deadline_date do
          create(:mentor_participant_declaration, :paid, participant_profile:, cpd_lead_provider:, cohort:)
        end
      end

      before do
        travel_to second_statement.deadline_date do
          Finance::ClawbackDeclaration.new(participant_declaration.reload).call
        end

        participant_declaration.clawed_back!
        participant_declaration
          .statement_line_items
          .awaiting_clawback
          .first
          .clawed_back!

        travel_to second_statement.deadline_date do
          create(:mentor_participant_declaration, :payable, participant_profile:, cpd_lead_provider:)
        end
      end

      it "returns correct counts" do
        second_statement_expectation = [
          {
            started_additions: 1,
            started_subtractions: 1,
          },
          {
            completed_additions: 0,
            completed_subtractions: 0,
          },
        ]

        expect(second_statement_calc.output_breakdown).to eql(second_statement_expectation)
      end
    end
  end
end
