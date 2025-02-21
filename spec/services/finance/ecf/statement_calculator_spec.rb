# frozen_string_literal: true

RSpec.describe Finance::ECF::StatementCalculator, mid_cohort: true do
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
      let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", uplift_breakdown:, banding_breakdown: []) }

      before do
        allow(Finance::ECF::OutputCalculator).to receive(:new).with(statement:).and_return(output_calculator)
      end

      it "calls OutputCalculator with correct params" do
        subject.total

        expect(Finance::ECF::OutputCalculator).to have_received(:new).with(statement:)
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

    describe "#voided_declarations" do
      before do
        create_declarations(:ect_participant_declaration, :voided, 5)
        create_declarations(:mentor_participant_declaration, :voided, 5)
      end

      it "returns all voided declarations" do
        expect(subject.voided_count).to eql(10)
        expect(subject.voided_declarations).to all(be_voided)
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
