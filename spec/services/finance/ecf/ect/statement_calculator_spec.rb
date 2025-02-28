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

      it "delegates to the correct UpliftCalculator" do
        expect(output_calculator.uplift.class).to eq(Finance::ECF::ECT::UpliftCalculator)
      end
    end

    def create_declarations(type, state, count)
      create_list(type, count, state:).tap do |declarations|
        declarations.each do |participant_declaration|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration:,
            state:,
          )
        end
      end
    end

    describe "#clawed_back_count" do
      before do
        create_declarations(:ect_participant_declaration, :clawed_back, 3)
        create_declarations(:mentor_participant_declaration, :clawed_back, 4)
      end

      it "returns ECT only clawed back declarations" do
        expect(subject.clawed_back_count).to eql(3)
      end
    end

    describe "#voided_count" do
      before do
        create_declarations(:ect_participant_declaration, :voided, 5)
        create_declarations(:mentor_participant_declaration, :voided, 5)
      end

      it "returns ECT only voided declarations" do
        expect(subject.voided_count).to eql(5)
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
