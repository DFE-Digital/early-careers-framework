# frozen_string_literal: true

RSpec.describe Finance::ECF::BandingCalculator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:call_off_contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }
  let(:bands) { call_off_contract.bands }

  let!(:statement) { create(:ecf_statement, :output_fee, cpd_lead_provider:) }
  let(:statement_one_month_ago) { create(:ecf_statement, :one_month_ago, cpd_lead_provider:) }
  let(:statement_two_months_ago) { create(:ecf_statement, :two_months_ago, cpd_lead_provider:) }
  let(:declaration_type) { "started" }

  let(:calculator_one_month_ago) { described_class.new(statement: statement_one_month_ago, declaration_type:) }
  let(:calculator_two_months_ago) { described_class.new(statement: statement_two_months_ago, declaration_type:) }
  subject { described_class.new(statement:, declaration_type:) }

  describe "#min" do
    it "returns min for all the bands" do
      expect(subject.min(:a)).to eq(1)
      expect(subject.min(:b)).to eq(bands[1].min)
      expect(subject.min(:c)).to eq(bands[2].min)
      expect(subject.min(:d)).to eq(bands[3].min)
      expect(subject.min(:e)).to be_nil
    end
  end

  describe "#max" do
    it "returns max for all the bands" do
      expect(subject.max(:a)).to eq(bands[0].max)
      expect(subject.max(:b)).to eq(bands[1].max)
      expect(subject.max(:c)).to eq(bands[2].max)
      expect(subject.max(:d)).to eq(bands[3].max)
      expect(subject.max(:e)).to be_nil
    end
  end

  describe "#calculate" do
    let(:letters) { %i[a b c d] }

    context "when there are no declarations" do
      it "returns zero" do
        letters.each do |letter|
          expect(subject.previous_count(letter)).to eq(0)
          expect(subject.count(letter)).to eq(0)
          expect(subject.additions(letter)).to eq(0)
          expect(subject.subtractions(letter)).to eq(0)
        end
      end
    end

    context "when there are declarations attached to another statement for different provider" do
      let(:other_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

      let!(:other_statement) { create(:ecf_statement, cpd_lead_provider: other_cpd_lead_provider, payment_date: 1.week.ago) }

      before do
        create(:call_off_contract, :with_minimal_bands, lead_provider: other_cpd_lead_provider.lead_provider)

        travel_to other_statement.deadline_date - 1.day do
          create(:ect_participant_declaration, :eligible, cpd_lead_provider: other_cpd_lead_provider)
        end
      end

      it "returns zero" do
        letters.each do |letter|
          expect(subject.previous_count(letter)).to eq(0)
          expect(subject.count(letter)).to eq(0)
          expect(subject.additions(letter)).to eq(0)
          expect(subject.subtractions(letter)).to eq(0)
        end
      end
    end

    context "when band A is partially filled" do
      before do
        travel_to statement.deadline_date do
          create(:ect_participant_declaration, :eligible, cpd_lead_provider:)
        end
      end

      it "returns the number of declarations" do
        expect(subject.previous_count(:a)).to eq(0)
        expect(subject.count(:a)).to eq(1)
        expect(subject.additions(:a)).to eq(1)
        expect(subject.subtractions(:a)).to eq(0)

        (letters - [:a]).each do |letter|
          expect(subject.previous_count(letter)).to eq(0)
          expect(subject.count(letter)).to eq(0)
          expect(subject.additions(letter)).to eq(0)
          expect(subject.subtractions(letter)).to eq(0)
        end
      end
    end

    context "when band A overflows to band B" do
      before do
        travel_to statement.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
          create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        end
      end

      it "returns the maximum number allowed in the band" do
        expect(subject.previous_count(:a)).to eq(0)
        expect(subject.count(:a)).to eq(2)
        expect(subject.additions(:a)).to eq(2)
        expect(subject.subtractions(:a)).to eq(0)

        expect(subject.previous_count(:b)).to eq(0)
        expect(subject.count(:b)).to eq(1)
        expect(subject.additions(:b)).to eq(1)
        expect(subject.subtractions(:b)).to eq(0)

        (letters - %i[a b]).each do |letter|
          expect(subject.previous_count(letter)).to eq(0)
          expect(subject.count(letter)).to eq(0)
          expect(subject.additions(letter)).to eq(0)
          expect(subject.subtractions(letter)).to eq(0)
        end
      end
    end

    context "when overfilled all bands" do
      before do
        travel_to statement.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 4, :eligible, cpd_lead_provider:, declaration_type:)
          create_list(:mentor_participant_declaration, 5, :eligible, cpd_lead_provider:, declaration_type:)
        end
      end

      it "returns the maximum fill for all bands" do
        letters.each do |letter|
          expect(subject.previous_count(letter)).to eq(0)
          expect(subject.count(letter)).to eq(2)
          expect(subject.additions(letter)).to eq(2)
          expect(subject.subtractions(letter)).to eq(0)
        end
      end
    end

    context "when there is a previous statement partially filling the band" do
      before do
        travel_to statement_one_month_ago.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
        end
      end

      context "there are no declarations on this statement" do
        it "returns previous count" do
          expect(subject.previous_count(:a)).to eq(1)
          expect(subject.count(:a)).to eq(0)
          expect(subject.additions(:a)).to eq(0)
          expect(subject.subtractions(:a)).to eq(0)

          (letters - %i[a]).each do |letter|
            expect(subject.previous_count(letter)).to eq(0)
            expect(subject.count(letter)).to eq(0)
            expect(subject.additions(letter)).to eq(0)
            expect(subject.subtractions(letter)).to eq(0)
          end
        end
      end

      context "there are declarations on this statement, partly filling it" do
        before do
          travel_to statement.deadline_date - 1.day do
            create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
          end
        end

        it "returns previous count and current count" do
          expect(subject.previous_count(:a)).to eq(1)
          expect(subject.count(:a)).to eq(1)
          expect(subject.additions(:a)).to eq(1)
          expect(subject.subtractions(:a)).to eq(0)

          (letters - %i[a]).each do |letter|
            expect(subject.previous_count(letter)).to eq(0)
            expect(subject.count(letter)).to eq(0)
            expect(subject.additions(letter)).to eq(0)
            expect(subject.subtractions(letter)).to eq(0)
          end
        end
      end

      context "there are declarations on this statement, over filling it" do
        before do
          travel_to statement.deadline_date - 1.day do
            create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
          end
        end

        it "returns previous count and current count, filling into band B" do
          expect(subject.previous_count(:a)).to eq(1)
          expect(subject.count(:a)).to eq(1)
          expect(subject.additions(:a)).to eq(1)
          expect(subject.subtractions(:a)).to eq(0)

          expect(subject.previous_count(:b)).to eq(0)
          expect(subject.count(:b)).to eq(1)
          expect(subject.additions(:b)).to eq(1)
          expect(subject.subtractions(:b)).to eq(0)

          (letters - %i[a b]).each do |letter|
            expect(subject.previous_count(letter)).to eq(0)
            expect(subject.count(letter)).to eq(0)
            expect(subject.additions(letter)).to eq(0)
            expect(subject.subtractions(letter)).to eq(0)
          end
        end
      end
    end

    context "when there is a previous statement totally filling the band" do
      before do
        travel_to statement_one_month_ago.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
          create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
        end
        travel_to statement.deadline_date - 1.day do
          create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
        end
      end

      it "returns previous count filled and current count overflows to band B" do
        expect(subject.previous_count(:a)).to eq(2)
        expect(subject.count(:a)).to eq(0)
        expect(subject.additions(:a)).to eq(0)
        expect(subject.subtractions(:a)).to eq(0)

        expect(subject.previous_count(:b)).to eq(0)
        expect(subject.count(:b)).to eq(1)
        expect(subject.additions(:b)).to eq(1)
        expect(subject.subtractions(:b)).to eq(0)

        (letters - %i[a b]).each do |letter|
          expect(subject.previous_count(letter)).to eq(0)
          expect(subject.count(letter)).to eq(0)
          expect(subject.additions(letter)).to eq(0)
          expect(subject.subtractions(letter)).to eq(0)
        end
      end
    end

    context "when previous statement filled band A and B, current statement overfilling to band C and D" do
      before do
        travel_to statement_one_month_ago.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
          create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        end
        travel_to statement.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
          create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        end
      end

      it "returns band values" do
        expect(subject.previous_count(:a)).to eq(2)
        expect(subject.count(:a)).to eq(0)
        expect(subject.additions(:a)).to eq(0)
        expect(subject.subtractions(:a)).to eq(0)

        expect(subject.previous_count(:b)).to eq(2)
        expect(subject.count(:b)).to eq(0)
        expect(subject.additions(:b)).to eq(0)
        expect(subject.subtractions(:b)).to eq(0)

        expect(subject.previous_count(:c)).to eq(0)
        expect(subject.count(:c)).to eq(2)
        expect(subject.additions(:c)).to eq(2)
        expect(subject.subtractions(:c)).to eq(0)

        expect(subject.previous_count(:d)).to eq(0)
        expect(subject.count(:d)).to eq(1)
        expect(subject.additions(:d)).to eq(1)
        expect(subject.subtractions(:d)).to eq(0)
      end
    end

    context "when there are clawbacks" do
      let(:declarations_one_month_ago) do
        # Create declarations for statement 1 month ago
        declarations = []
        travel_to statement_one_month_ago.deadline_date - 1.day do
          declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
          declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        end
        declarations
      end
      let(:declarations_two_months_ago) do
        # Create declarations for statement 2 months ago
        declarations = []
        travel_to statement_two_months_ago.deadline_date - 1.day do
          declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
          declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        end
        declarations
      end

      context "when there are no additions" do
        before do
          declarations_one_month_ago

          # Mark statement 1 month ago as paid
          Statements::MarkAsPayable.new(statement_one_month_ago).call
          Statements::MarkAsPaid.new(statement_one_month_ago).call

          # Create clawbacks for this month statement from declarations 1 month ago
          travel_to statement.deadline_date - 1.day do
            declarations_one_month_ago.sample(2).each do |dec|
              Finance::ClawbackDeclaration.new(dec.reload).call
            end
          end
        end

        it "returns values for statement 1 month ago" do
          expect(calculator_one_month_ago.previous_count(:a)).to eq(0)
          expect(calculator_one_month_ago.count(:a)).to eq(2)
          expect(calculator_one_month_ago.additions(:a)).to eq(2)
          expect(calculator_one_month_ago.subtractions(:a)).to eq(0)

          expect(calculator_one_month_ago.previous_count(:b)).to eq(0)
          expect(calculator_one_month_ago.count(:b)).to eq(2)
          expect(calculator_one_month_ago.additions(:b)).to eq(2)
          expect(calculator_one_month_ago.subtractions(:b)).to eq(0)

          (letters - %i[a b]).each do |letter|
            expect(calculator_one_month_ago.previous_count(letter)).to eq(0)
            expect(calculator_one_month_ago.count(letter)).to eq(0)
            expect(calculator_one_month_ago.additions(letter)).to eq(0)
            expect(calculator_one_month_ago.subtractions(letter)).to eq(0)
          end
        end

        it "returns values with clawbacks for this month statement" do
          expect(subject.previous_count(:a)).to eq(2)
          expect(subject.count(:a)).to eq(0)
          expect(subject.additions(:a)).to eq(0)
          expect(subject.subtractions(:a)).to eq(0)

          expect(subject.previous_count(:b)).to eq(2)
          expect(subject.count(:b)).to eq(-2)
          expect(subject.additions(:b)).to eq(0)
          expect(subject.subtractions(:b)).to eq(2)

          (letters - %i[a b]).each do |letter|
            expect(subject.previous_count(letter)).to eq(0)
            expect(subject.count(letter)).to eq(0)
            expect(subject.additions(letter)).to eq(0)
            expect(subject.subtractions(letter)).to eq(0)
          end
        end
      end

      context "when there are 3 additions" do
        before do
          declarations_one_month_ago

          # Mark statement 1 month ago as paid
          Statements::MarkAsPayable.new(statement_one_month_ago).call
          Statements::MarkAsPaid.new(statement_one_month_ago).call

          travel_to statement.deadline_date - 1.day do
            # Create clawbacks for this month statement from declarations 1 month ago
            declarations_one_month_ago.sample(2).each do |dec|
              Finance::ClawbackDeclaration.new(dec.reload).call
            end

            # Create declarations for this month statement
            create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
            create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
          end
        end

        it "returns values for statement 1 month ago" do
          expect(calculator_one_month_ago.previous_count(:a)).to eq(0)
          expect(calculator_one_month_ago.count(:a)).to eq(2)
          expect(calculator_one_month_ago.additions(:a)).to eq(2)
          expect(calculator_one_month_ago.subtractions(:a)).to eq(0)

          expect(calculator_one_month_ago.previous_count(:b)).to eq(0)
          expect(calculator_one_month_ago.count(:b)).to eq(2)
          expect(calculator_one_month_ago.additions(:b)).to eq(2)
          expect(calculator_one_month_ago.subtractions(:b)).to eq(0)

          (letters - %i[a b]).each do |letter|
            expect(calculator_one_month_ago.previous_count(letter)).to eq(0)
            expect(calculator_one_month_ago.count(letter)).to eq(0)
            expect(calculator_one_month_ago.additions(letter)).to eq(0)
            expect(calculator_one_month_ago.subtractions(letter)).to eq(0)
          end
        end

        it "returns values with clawbacks for this month statement" do
          expect(subject.previous_count(:a)).to eq(2)
          expect(subject.count(:a)).to eq(0)
          expect(subject.additions(:a)).to eq(0)
          expect(subject.subtractions(:a)).to eq(0)

          expect(subject.previous_count(:b)).to eq(2)
          expect(subject.count(:b)).to eq(0)
          expect(subject.additions(:b)).to eq(0)
          expect(subject.subtractions(:b)).to eq(0)

          expect(subject.previous_count(:c)).to eq(0)
          expect(subject.count(:c)).to eq(1)
          expect(subject.additions(:c)).to eq(2)
          expect(subject.subtractions(:c)).to eq(1)

          expect(subject.previous_count(:d)).to eq(0)
          expect(subject.count(:d)).to eq(0)
          expect(subject.additions(:d)).to eq(1)
          expect(subject.subtractions(:d)).to eq(1)
        end
      end

      context "when clawbacks present in 3 consecutive statements" do
        before do
          declarations_two_months_ago
          # Mark statement 2 months ago as paid
          Statements::MarkAsPayable.new(statement_two_months_ago).call
          Statements::MarkAsPaid.new(statement_two_months_ago).call

          declarations_one_month_ago
          # Create 1 clawback for statement 1 month ago from declarations 2 months ago
          travel_to statement_one_month_ago.deadline_date - 1.day do
            Finance::ClawbackDeclaration.new(declarations_two_months_ago[0].reload).call
          end
          # Mark statement 1 months ago as paid
          Statements::MarkAsPayable.new(statement_one_month_ago).call
          Statements::MarkAsPaid.new(statement_one_month_ago).call

          travel_to statement.deadline_date - 1.day do
            # Create declarations for this month statement
            create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
            create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)

            # Create 1 clawback for this month statement from declarations 2 months ago
            Finance::ClawbackDeclaration.new(declarations_two_months_ago[1].reload).call

            # Create 1 clawback for this month statement from declarations 1 month ago
            Finance::ClawbackDeclaration.new(declarations_one_month_ago[0].reload).call
          end
        end

        it "returns values for statement 2 months ago" do
          expect(calculator_two_months_ago.previous_count(:a)).to eq(0)
          expect(calculator_two_months_ago.count(:a)).to eq(2)
          expect(calculator_two_months_ago.additions(:a)).to eq(2)
          expect(calculator_two_months_ago.subtractions(:a)).to eq(0)

          expect(calculator_two_months_ago.previous_count(:b)).to eq(0)
          expect(calculator_two_months_ago.count(:b)).to eq(2)
          expect(calculator_two_months_ago.additions(:b)).to eq(2)
          expect(calculator_two_months_ago.subtractions(:b)).to eq(0)

          (letters - %i[a b]).each do |letter|
            expect(calculator_two_months_ago.previous_count(letter)).to eq(0)
            expect(calculator_two_months_ago.count(letter)).to eq(0)
            expect(calculator_two_months_ago.additions(letter)).to eq(0)
            expect(calculator_two_months_ago.subtractions(letter)).to eq(0)
          end
        end

        it "returns values for statement 1 month ago" do
          expect(calculator_one_month_ago.previous_count(:a)).to eq(2)
          expect(calculator_one_month_ago.count(:a)).to eq(0)
          expect(calculator_one_month_ago.additions(:a)).to eq(0)
          expect(calculator_one_month_ago.subtractions(:a)).to eq(0)

          expect(calculator_one_month_ago.previous_count(:b)).to eq(2)
          expect(calculator_one_month_ago.count(:b)).to eq(0)
          expect(calculator_one_month_ago.additions(:b)).to eq(0)
          expect(calculator_one_month_ago.subtractions(:b)).to eq(0)

          expect(calculator_one_month_ago.previous_count(:c)).to eq(0)
          expect(calculator_one_month_ago.count(:c)).to eq(2)
          expect(calculator_one_month_ago.additions(:c)).to eq(2)
          expect(calculator_one_month_ago.subtractions(:c)).to eq(0)

          expect(calculator_one_month_ago.previous_count(:d)).to eq(0)
          expect(calculator_one_month_ago.count(:d)).to eq(1)
          expect(calculator_one_month_ago.additions(:d)).to eq(2)
          expect(calculator_one_month_ago.subtractions(:d)).to eq(1)
        end

        it "returns values for this month statement" do
          expect(subject.previous_count(:a)).to eq(2)
          expect(subject.count(:a)).to eq(0)
          expect(subject.additions(:a)).to eq(0)
          expect(subject.subtractions(:a)).to eq(0)

          expect(subject.previous_count(:b)).to eq(2)
          expect(subject.count(:b)).to eq(0)
          expect(subject.additions(:b)).to eq(0)
          expect(subject.subtractions(:b)).to eq(0)

          expect(subject.previous_count(:c)).to eq(2)
          expect(subject.count(:c)).to eq(0)
          expect(subject.additions(:c)).to eq(0)
          expect(subject.subtractions(:c)).to eq(0)

          expect(subject.previous_count(:d)).to eq(1)
          expect(subject.count(:d)).to eq(-1)
          expect(subject.additions(:d)).to eq(1)
          expect(subject.subtractions(:d)).to eq(2)
        end
      end

      context "when there is a clawback followed by a declaration again" do
        let!(:participant_declaration) do
          travel_to statement_two_months_ago.deadline_date - 1.day do
            create(:ect_participant_declaration, :eligible, cpd_lead_provider:, declaration_type:)
          end
        end
        let(:participant_profile) { participant_declaration.participant_profile }

        before do
          # Mark statement 2 months ago as paid
          Statements::MarkAsPayable.new(statement_two_months_ago).call
          Statements::MarkAsPaid.new(statement_two_months_ago).call

          travel_to statement_one_month_ago.deadline_date - 1.day do
            # Create clawback for statement 1 month ago for participant_declaration
            Finance::ClawbackDeclaration.new(participant_declaration.reload).call

            # Mark statement 1 month ago as paid
            Statements::MarkAsPayable.new(statement_one_month_ago).call
            Statements::MarkAsPaid.new(statement_one_month_ago).call
          end

          # Create declaration for this month statement with existing participant_profile
          travel_to statement.deadline_date - 1.day do
            create(:ect_participant_declaration, :payable, participant_profile:, cpd_lead_provider:)
          end
        end

        it "returns values for statement 2 months ago" do
          expect(calculator_two_months_ago.previous_count(:a)).to eq(0)
          expect(calculator_two_months_ago.count(:a)).to eq(1)
          expect(calculator_two_months_ago.additions(:a)).to eq(1)
          expect(calculator_two_months_ago.subtractions(:a)).to eq(0)

          (letters - %i[a]).each do |letter|
            expect(calculator_two_months_ago.previous_count(letter)).to eq(0)
            expect(calculator_two_months_ago.count(letter)).to eq(0)
            expect(calculator_two_months_ago.additions(letter)).to eq(0)
            expect(calculator_two_months_ago.subtractions(letter)).to eq(0)
          end
        end

        it "returns values for statement 1 month ago" do
          expect(calculator_one_month_ago.previous_count(:a)).to eq(1)
          expect(calculator_one_month_ago.count(:a)).to eq(-1)
          expect(calculator_one_month_ago.additions(:a)).to eq(0)
          expect(calculator_one_month_ago.subtractions(:a)).to eq(1)

          (letters - %i[a]).each do |letter|
            expect(calculator_one_month_ago.previous_count(letter)).to eq(0)
            expect(calculator_one_month_ago.count(letter)).to eq(0)
            expect(calculator_one_month_ago.additions(letter)).to eq(0)
            expect(calculator_one_month_ago.subtractions(letter)).to eq(0)
          end
        end

        it "returns values for this month statement" do
          expect(subject.previous_count(:a)).to eq(0)
          expect(subject.count(:a)).to eq(1)
          expect(subject.additions(:a)).to eq(1)
          expect(subject.subtractions(:a)).to eq(0)

          (letters - %i[a]).each do |letter|
            expect(subject.previous_count(letter)).to eq(0)
            expect(subject.count(letter)).to eq(0)
            expect(subject.additions(letter)).to eq(0)
            expect(subject.subtractions(letter)).to eq(0)
          end
        end
      end

      %w[started retained-1 retained-2 retained-3 retained-4 completed].each do |dec_type|
        context "with #{dec_type} declaration type" do
          let(:declaration_type) { dec_type }

          before do
            travel_to statement.deadline_date - 1.day do
              # Forces declaration type to be within cutoff
              Finance::Milestone.update_all(start_date: Date.yesterday, milestone_date: Date.tomorrow)

              create(:ect_participant_declaration, :eligible, cpd_lead_provider:, declaration_type:)
              create(:mentor_participant_declaration, :eligible, cpd_lead_provider:, declaration_type:)
            end
          end

          it "returns values for this month statement" do
            expect(subject.previous_count(:a)).to eq(0)
            expect(subject.count(:a)).to eq(2)
            expect(subject.additions(:a)).to eq(2)
            expect(subject.subtractions(:a)).to eq(0)

            (letters - %i[a]).each do |letter|
              expect(subject.previous_count(letter)).to eq(0)
              expect(subject.count(letter)).to eq(0)
              expect(subject.additions(letter)).to eq(0)
              expect(subject.subtractions(letter)).to eq(0)
            end
          end
        end
      end

      %w[extended-1 extended-2 extended-3].each do |dec_type|
        context "with #{dec_type} declaration type" do
          let!(:schedule) { create(:ecf_extended_schedule) }
          let(:declaration_type) { dec_type }

          before do
            travel_to statement.deadline_date - 1.day do
              create(:ect_participant_declaration, :extended, cpd_lead_provider:, declaration_type:)
              create(:mentor_participant_declaration, :extended, cpd_lead_provider:, declaration_type:)
            end
          end

          it "returns values for this month statement" do
            expect(subject.previous_count(:a)).to eq(0)
            expect(subject.count(:a)).to eq(2)
            expect(subject.additions(:a)).to eq(2)
            expect(subject.subtractions(:a)).to eq(0)

            (letters - %i[a]).each do |letter|
              expect(subject.previous_count(letter)).to eq(0)
              expect(subject.count(letter)).to eq(0)
              expect(subject.additions(letter)).to eq(0)
              expect(subject.subtractions(letter)).to eq(0)
            end
          end
        end
      end
    end
  end
end
