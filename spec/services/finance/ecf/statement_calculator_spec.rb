# frozen_string_literal: true

RSpec.describe Finance::ECF::StatementCalculator, mid_cohort: true do
  it_behaves_like "a Finance ECF statement calculator" do
    describe "#output_calculator" do
      let(:output_calculator) { subject.send(:output_calculator) }

      it "delegates to the correct OutputCalculator" do
        expect(output_calculator.class).to eq(Finance::ECF::OutputCalculator)
      end

      it "delegates to the correct BandingCalculator" do
        expect(output_calculator.banding_for(declaration_type: "started").class).to eq(Finance::ECF::BandingCalculator)
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

      it { expect(subject.clawed_back_count).to eql(7) }
    end

    describe "#voided_count" do
      before do
        create_declarations(:ect_participant_declaration, :voided, 5)
        create_declarations(:mentor_participant_declaration, :voided, 5)
      end

      it "returns all voided declarations" do
        expect(subject.voided_count).to eql(10)
      end
    end
  end

  describe "#ect?" do
    it { expect(described_class.new(statement: nil).ect?).to be(false) }
  end

  describe "#mentor?" do
    it { expect(described_class.new(statement: nil).mentor?).to be(false) }
  end
end
