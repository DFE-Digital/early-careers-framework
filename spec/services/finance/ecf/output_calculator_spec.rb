# frozen_string_literal: true

RSpec.describe Finance::ECF::OutputCalculator do
  let(:first_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 6.months.ago) }
  let(:second_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 3.months.ago) }
  let(:third_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 0.months.ago) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  let(:first_statement_calc) { described_class.new(statement: first_statement) }
  let(:second_statement_calc) { described_class.new(statement: second_statement) }
  let(:third_statement_calc) { described_class.new(statement: third_statement) }

  let(:relevant_started_keys) do
    %i[
      band
      min
      max
      previous_started_count
      started_count
      started_additions
      started_subtractions
    ]
  end

  describe "#fee_for_declaration" do
    subject { first_statement_calc }

    it do
      expect(subject.fee_for_declaration(band_letter: :a, type: :started)).to eql(48)
      expect(subject.fee_for_declaration(band_letter: :a, type: :retained_1)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :completed)).to eql(48)

      expect(subject.fee_for_declaration(band_letter: :b, type: :started)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :b, type: :retained_2)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :completed)).to eql(36)

      expect(subject.fee_for_declaration(band_letter: :c, type: :started)).to eql(24)
      expect(subject.fee_for_declaration(band_letter: :c, type: :retained_3)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :completed)).to eql(24)

      expect(subject.fee_for_declaration(band_letter: :d, type: :started)).to eql(12)
      expect(subject.fee_for_declaration(band_letter: :d, type: :retained_3)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :completed)).to eql(12)
    end
  end

  describe "#banding_breakdown" do
    context "when nada declarations" do
      it "returns empty bands" do
        expected = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(expected)
      end
    end

    context "when partially filled bands" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 1,
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

      it "returns correct bands" do
        expected = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(expected)
      end
    end

    context "when fully filled bands" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 2,
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

      it "returns correct bands" do
        expected = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(expected)
      end
    end

    context "when multiple bands" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 7,
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

      it "returns correct bands" do
        expected = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(expected)
      end
    end

    context "when overfilled all bands" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 9,
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

      it "does not count extra declarations" do
        expected = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(expected)
      end
    end

    context "next statement is present" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 3,
          state: :paid
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement: first_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end

        declarations = create_list(
          :ect_participant_declaration, 3,
          state: :payable
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement: second_statement,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "counts bands from where it left off" do
        expected = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 2,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 1,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        expect(second_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(expected)
      end
    end

    context "when clawbacks present" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 5,
          state: :paid
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
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        second_statement_expectation = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 2,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 2,
            started_count: -1,
            started_additions: 0,
            started_subtractions: 1,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 1,
            started_count: -1,
            started_additions: 0,
            started_subtractions: 1,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(first_statement_expectation)
        expect(second_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(second_statement_expectation)
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
          :ect_participant_declaration, 3,
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
          :ect_participant_declaration, 3,
          state: :paid
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
          :ect_participant_declaration, 3,
          state: :payable
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
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 0,
            started_count: 2,
            started_additions: 2,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 0,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        second_statement_expectation = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 2,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 1,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 0,
            started_count: 1,
            started_additions: 2,
            started_subtractions: 1,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
        ]

        third_statement_expectation = [
          {
            band: :a,
            min: 1,
            max: 2,
            previous_started_count: 2,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,
            previous_started_count: 2,
            started_count: 0,
            started_additions: 0,
            started_subtractions: 0,
          },
          {
            band: :c,
            min: 5,
            max: 6,
            previous_started_count: 1,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,
          },
          {
            band: :d,
            min: 7,
            max: 8,
            previous_started_count: 0,
            started_count: 0,
            started_additions: 2,
            started_subtractions: 2,
          },
        ]

        expect(first_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(first_statement_expectation)
        expect(second_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(second_statement_expectation)
        expect(third_statement_calc.banding_breakdown.map { |e| e.slice(*relevant_started_keys) }).to eql(third_statement_expectation)
      end
    end

    context "uplifts" do
      context "when there an no uplifts" do
        let(:expected) do
          {
            previous_count: 0,
            count: 0,
            additions: 0,
            subtractions: 0,
          }
        end

        it "returns zero current and previous uplifts" do
          expect(first_statement_calc.uplift_breakdown).to eql(expected)
        end
      end

      context "when there are uplifts" do
        before do
          declarations = create_list(
            :ect_participant_declaration, 2,
            state: :paid,
            pupil_premium_uplift: true
          )

          declarations.each do |dec|
            Finance::StatementLineItem.create!(
              statement: first_statement,
              participant_declaration: dec,
              state: dec.state,
            )
          end
        end

        let(:expected) do
          {
            previous_count: 0,
            count: 2,
            additions: 2,
            subtractions: 0,
          }
        end

        it "returns current uplifts" do
          expect(first_statement_calc.uplift_breakdown).to eql(expected)
        end
      end

      context "when there are uplifts but not on started declarations" do
        before do
          declarations = create_list(
            :ect_participant_declaration, 2,
            state: :paid,
            pupil_premium_uplift: true,
            declaration_type: "retained-1"
          )

          declarations.each do |dec|
            Finance::StatementLineItem.create!(
              statement: first_statement,
              participant_declaration: dec,
              state: dec.state,
            )
          end
        end

        let(:expected) do
          {
            previous_count: 0,
            count: 0,
            additions: 0,
            subtractions: 0,
          }
        end

        it "does not count them" do
          expect(first_statement_calc.uplift_breakdown).to eql(expected)
        end
      end

      context "when there is net negative of uplifts on a single statement" do
        before do
          declarations = create_list(
            :ect_participant_declaration, 2,
            state: :paid,
            pupil_premium_uplift: true
          )

          declarations.each do |dec|
            Finance::StatementLineItem.create!(
              statement: first_statement,
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
              statement: second_statement,
              participant_declaration: line_item.participant_declaration,
              state: "awaiting_clawback",
            )

            line_item.participant_declaration.update!(state: "awaiting_clawback")
          end
        end

        let(:expected) do
          {
            previous_count: 2,
            count: -1,
            additions: 0,
            subtractions: 1,
          }
        end

        it "returns negative uplifts" do
          expect(second_statement_calc.uplift_breakdown).to eql(expected)
        end
      end

      context "when there are previous uplifts" do
        before do
          setup_statement_one
          setup_statement_two
          setup_statement_three
        end

        def setup_statement_one
          declarations = create_list(
            :ect_participant_declaration, 3,
            state: :paid,
            pupil_premium_uplift: true
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
            :ect_participant_declaration, 3,
            state: :paid,
            pupil_premium_uplift: true
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
            :ect_participant_declaration, 3,
            state: :payable,
            pupil_premium_uplift: true
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

        let(:statement_one_expectation) do
          {
            previous_count: 0,
            count: 3,
            additions: 3,
            subtractions: 0,
          }
        end

        let(:statement_two_expectation) do
          {
            previous_count: 3,
            count: 2,
            additions: 3,
            subtractions: 1,
          }
        end

        let(:statement_three_expectation) do
          {
            previous_count: 5,
            count: 1,
            additions: 3,
            subtractions: 2,
          }
        end

        it "returns correct uplifts" do
          expect(first_statement_calc.uplift_breakdown).to eql(statement_one_expectation)
          expect(second_statement_calc.uplift_breakdown).to eql(statement_two_expectation)
          expect(third_statement_calc.uplift_breakdown).to eql(statement_three_expectation)
        end
      end
    end
  end
end
