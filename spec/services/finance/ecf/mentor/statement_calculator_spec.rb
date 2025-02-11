# frozen_string_literal: true

RSpec.describe Finance::ECF::Mentor::StatementCalculator, mid_cohort: true do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let!(:statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 1.week.ago) }
  let!(:contract) { create(:mentor_call_off_contract, lead_provider:) }

  subject { described_class.new(statement:) }

  describe "#total" do
    let(:output_breakdown) do
      [
        {
          started_additions: 5,
          started_subtractions: 2,
        },
        {
          completed_additions: 3,
          completed_subtractions: 1,
        },
      ]
    end
    let(:output_calculator) { instance_double("Finance::ECF::Mentor::OutputCalculator", output_breakdown:) }

    before do
      allow(Finance::ECF::Mentor::OutputCalculator).to receive(:new).with(statement:).and_return(output_calculator)
      allow(output_calculator).to receive(:fee_for_declaration).and_return(500)
    end

    context "when VAT is not applicable" do
      it "calculates the total" do
        expect(subject.total(with_vat: false)).to eql(2500)
      end
    end

    context "when VAT is applicable" do
      it "calculates the total" do
        expect(subject.total(with_vat: true)).to eq(3000)
      end
    end
  end

  describe "#additions_for_started" do
    let(:output_breakdown) do
      [
        {
          started_additions: 4,
          started_subtractions: 0,
        },
        {
          completed_additions: 2,
          completed_subtractions: 1,
        },
      ]
    end

    let(:output_calculator) { instance_double("Finance::ECF::Mentor::OutputCalculator") }

    before do
      allow(Finance::ECF::Mentor::OutputCalculator).to receive(:new).and_return(output_calculator)
      allow(output_calculator).to receive(:output_breakdown).and_return(output_breakdown)
      allow(output_calculator).to receive(:fee_for_declaration).and_return(500)
    end

    it "returns correct value" do
      expect(subject.additions_for_started).to eql(2000)
    end
  end

  describe "#started_count" do
    let(:output_breakdown) do
      [
        {
          started_additions: 10,
          started_subtractions: 0,
        },
        {
          completed_additions: 2,
          completed_subtractions: 1,
        },
      ]
    end
    let(:output_calculator) { instance_double("Finance::ECF::Mentor::OutputCalculator", output_breakdown:) }

    before do
      allow(Finance::ECF::Mentor::OutputCalculator).to receive(:new).and_return(output_calculator)
    end

    it "returns correct value" do
      expect(subject.started_count).to eql(10)
    end
  end

  describe "#completed_count" do
    let(:output_breakdown) do
      [
        {
          started_additions: 10,
          started_subtractions: 0,
        },
        {
          completed_additions: 20,
          completed_subtractions: 1,
        },
      ]
    end
    let(:output_calculator) { instance_double("Finance::ECF::Mentor::OutputCalculator", output_breakdown:) }

    before do
      allow(Finance::ECF::Mentor::OutputCalculator).to receive(:new).and_return(output_calculator)
    end

    it "returns correct value" do
      expect(subject.completed_count).to eql(20)
    end
  end

  describe "#declaration_types_for_display" do
    it "returns all declaration types available for display" do
      expect(subject.declaration_types_for_display).to eql(
        %i[
          started
          completed
        ],
      )
    end
  end

  describe "#voided_declarations" do
    before do
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
    end

    it "returns only voided mentor declarations" do
      expect(subject.voided_declarations.size).to eql(5)
      expect(subject.voided_declarations.pluck(:state, :type).uniq.flatten).to eql(["voided", "ParticipantDeclaration::Mentor"])
    end
  end
end
