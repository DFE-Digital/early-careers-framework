# frozen_string_literal: true

RSpec.describe Finance::ECF::ECT::OutputCalculator do
  let(:first_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 6.months.ago) }
  let(:second_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 4.months.ago) }
  let(:third_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 2.months.ago) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  let(:first_statement_calc) { described_class.new(statement: first_statement) }
  let(:second_statement_calc) { described_class.new(statement: second_statement) }
  let(:third_statement_calc) { described_class.new(statement: third_statement) }

  subject { first_statement_calc }

  describe "#band_for" do
    let(:letters) { %i[a b c d] }
    let(:declaration_types) do
      %w[
        started
        retained-1
        retained-2
        retained-3
        retained-4
        completed
        extended-1
        extended-2
        extended-3
      ]
    end

    before do
      declaration_types.each do |declaration_type|
        mock_banding = instance_double(
          Finance::ECF::ECT::BandingCalculator,
          previous_count: 5,
          count: 10,
          additions: 15,
          subtractions: 5,
        )

        expect(Finance::ECF::ECT::BandingCalculator).to receive(:new)
          .with(statement: first_statement, declaration_type:)
          .and_return(mock_banding)
      end
    end

    it "correctly delegates to ECT banding calculator" do
      declaration_types.each do |declaration_type|
        letters.each do |letter|
          expect(subject.banding_for(declaration_type:).previous_count(letter)).to eq(5)
          expect(subject.banding_for(declaration_type:).count(letter)).to eq(10)
          expect(subject.banding_for(declaration_type:).additions(letter)).to eq(15)
          expect(subject.banding_for(declaration_type:).subtractions(letter)).to eq(5)
        end
      end
    end
  end

  describe "#fee_for_declaration" do
    it "returns correct fees" do
      expect(subject.fee_for_declaration(band_letter: :a, type: :started)).to eql(48)
      expect(subject.fee_for_declaration(band_letter: :a, type: :retained_1)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :retained_2)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :retained_3)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :retained_4)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :completed)).to eql(48)
      expect(subject.fee_for_declaration(band_letter: :a, type: :extended_1)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :extended_2)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :a, type: :extended_3)).to eql(36)

      expect(subject.fee_for_declaration(band_letter: :b, type: :started)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :b, type: :retained_1)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :retained_2)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :retained_3)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :retained_4)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :completed)).to eql(36)
      expect(subject.fee_for_declaration(band_letter: :b, type: :extended_1)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :extended_2)).to eql(27)
      expect(subject.fee_for_declaration(band_letter: :b, type: :extended_3)).to eql(27)

      expect(subject.fee_for_declaration(band_letter: :c, type: :started)).to eql(24)
      expect(subject.fee_for_declaration(band_letter: :c, type: :retained_1)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :retained_2)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :retained_3)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :retained_4)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :completed)).to eql(24)
      expect(subject.fee_for_declaration(band_letter: :c, type: :extended_1)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :extended_2)).to eql(18)
      expect(subject.fee_for_declaration(band_letter: :c, type: :extended_3)).to eql(18)

      expect(subject.fee_for_declaration(band_letter: :d, type: :started)).to eql(12)
      expect(subject.fee_for_declaration(band_letter: :d, type: :retained_1)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :retained_2)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :retained_3)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :retained_4)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :completed)).to eql(12)
      expect(subject.fee_for_declaration(band_letter: :d, type: :extended_1)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :extended_2)).to eql(9)
      expect(subject.fee_for_declaration(band_letter: :d, type: :extended_3)).to eql(9)
    end
  end

  describe "#uplift_breakdown" do
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
        ) + create_list(
          :mentor_participant_declaration, 2,
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
        ) + create_list(
          :mentor_participant_declaration, 2,
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
        ) + create_list(
          :mentor_participant_declaration, 2,
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
          .merge!(ParticipantDeclaration.ect)
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
        ) + create_list(
          :mentor_participant_declaration, 3,
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
        ) + create_list(
          :mentor_participant_declaration, 3,
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
          .order(Arel.sql("RANDOM()"))
          .merge!(ParticipantDeclaration.ect)
          .limit(1)

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
        ) + create_list(
          :mentor_participant_declaration, 3,
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
          .merge!(ParticipantDeclaration.ect)
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
          .merge!(ParticipantDeclaration.ect)
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
