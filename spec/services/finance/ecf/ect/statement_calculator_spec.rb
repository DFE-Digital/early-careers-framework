# frozen_string_literal: true

RSpec.describe Finance::ECF::ECT::StatementCalculator do
  it_behaves_like "a Finance ECF statement calculator" do
    describe "#output_calculator" do
      let(:output_calculator) { subject.send(:output_calculator) }

      it "delegates to the correct OutputCalculator" do
        expect(output_calculator.class).to eq(Finance::ECF::ECT::OutputCalculator)
      end

      it "delegates to the correct BandingCalculator" do
        expect(output_calculator.banding_for(declaration_type: "started").class).to eq(Finance::ECF::ECT::BandingCalculator)
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

      it "returns ECT only voided declarations" do
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
