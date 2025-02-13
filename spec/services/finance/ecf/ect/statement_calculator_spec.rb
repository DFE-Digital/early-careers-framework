# frozen_string_literal: true

RSpec.describe Finance::ECF::ECT::StatementCalculator do
  it_behaves_like "a Finance ECF statement calculator" do
    describe "#total" do
      let(:uplift_breakdown) do
        {
          previous_count: 0,
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end
      let(:output_calculator) { instance_double("Finance::ECF::ECT::OutputCalculator", uplift_breakdown:, banding_breakdown: []) }

      before do
        allow(Finance::ECF::ECT::OutputCalculator).to receive(:new).with(statement:).and_return(output_calculator)
      end

      it "calls OutputCalculator with correct params" do
        subject.total

        expect(Finance::ECF::ECT::OutputCalculator).to have_received(:new).with(statement:)
      end
    end

    describe "#voided_declarations" do
      let(:cohort) { statement.cohort }

      before do
        declarations = create_list(
          :ect_participant_declaration, 5,
          state: :voided
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end

        declarations = create_list(
          :mentor_participant_declaration, 5,
          state: :voided
        )

        declarations.each do |dec|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: dec,
            state: dec.state,
          )
        end
      end

      it "returns all voided declarations" do
        expect(subject.voided_declarations.size).to eql(5)
        expect(subject.voided_declarations.pluck(:state).uniq).to eql(%w[voided])
      end
    end
  end

  describe "#ect?" do
    it { expect(described_class.new(statement: nil).ect?).to be(true) }
  end

  describe "#mentor?" do
    it { expect(described_class.new(statement: nil).mentor?).to be(false) }
  end
end
