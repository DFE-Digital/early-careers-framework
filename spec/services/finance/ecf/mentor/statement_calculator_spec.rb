# frozen_string_literal: true

RSpec.describe Finance::ECF::Mentor::StatementCalculator, mid_cohort: true do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let!(:statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 1.week.ago) }
  let!(:contract) { create(:mentor_call_off_contract, lead_provider:) }

  subject { described_class.new(statement:) }

  before do
    output_calculator = subject.send(:output_calculator)

    # Mock output_breakdown values
    if defined?(mock_output_breakdown)
      allow(output_calculator).to receive(:output_breakdown).and_return(mock_output_breakdown.stringify_keys)
    end

    # Mock fee_for_declaration
    if defined?(mock_fee_for_declaration)
      allow(output_calculator).to receive(:fee_for_declaration).and_return(*mock_fee_for_declaration)
    end
  end

  describe "#total" do
    let(:mock_output_breakdown) do
      {
        started_additions: 5,
        started_subtractions: 2,

        completed_additions: 3,
        completed_subtractions: 1,
      }
    end
    let(:mock_fee_for_declaration) { 500 }

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

  describe "#started_fee_per_declaration" do
    let(:mock_output_breakdown) do
      {
        started_additions: 4,
        started_subtractions: 0,

        completed_additions: 2,
        completed_subtractions: 1,
      }
    end
    let(:mock_fee_for_declaration) { 500 }

    it "returns correct value" do
      expect(subject.started_fee_per_declaration).to eql(500)
    end
  end

  describe "#additions_for_started" do
    let(:mock_output_breakdown) do
      {
        started_additions: 4,
        started_subtractions: 0,

        completed_additions: 2,
        completed_subtractions: 1,
      }
    end
    let(:mock_fee_for_declaration) { 500 }

    it "returns correct value" do
      expect(subject.additions_for_started).to eql(2000)
    end
  end

  describe "#started_count" do
    let(:mock_output_breakdown) do
      {
        started_additions: 10,
        started_subtractions: 0,

        completed_additions: 2,
        completed_subtractions: 1,
      }
    end

    it "returns correct value" do
      expect(subject.started_count).to eql(10)
    end
  end

  describe "#completed_count" do
    let(:mock_output_breakdown) do
      {
        started_additions: 10,
        started_subtractions: 0,

        completed_additions: 20,
        completed_subtractions: 1,
      }
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

  describe "#voided_count" do
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

    it "returns the # of voided mentor declarations" do
      expect(subject.voided_count).to eql(5)
    end
  end

  describe "#fee_for_declaration" do
    let(:output_calculator) { subject.send(:output_calculator) }
    let(:mock_fee_for_declaration) { 100.0 }

    it "calls OutputCalculator#fee_for_declaration with correct params" do
      expect(output_calculator).to receive(:fee_for_declaration).with(type: "started")

      expect(subject.fee_for_declaration(type: "started")).to eq(100.0)
    end
  end

  describe "#clawbacks_breakdown" do
    let(:mock_output_breakdown) do
      {
        started_additions: 0,
        started_subtractions: 2,

        completed_additions: 0,
        completed_subtractions: 3,
      }
    end
    let(:mock_fee_for_declaration) { 100.0 }

    it "returns clawbacks breakdown" do
      expect(subject.clawbacks_breakdown).to eq([
        {
          count: 2,
          declaration_type: "Started",
          fee: -100.0,
          subtotal: -200.0,
        },
        {
          count: 3,
          declaration_type: "Completed",
          fee: -100.0,
          subtotal: -300.0,
        },
      ])
    end
  end

  describe "#ect?" do
    it { expect(subject.ect?).to be(false) }
  end

  describe "#mentor?" do
    it { expect(subject.mentor?).to be(true) }
  end

  describe "#clawed_back_count" do
    before do
      declarations = create_list(
        :mentor_participant_declaration, 5,
        state: :clawed_back
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
        state: :clawed_back
      )

      declarations.each do |dec|
        Finance::StatementLineItem.create!(
          statement:,
          participant_declaration: dec,
          state: dec.state,
        )
      end
    end

    it "returns the # of clawed back mentor declarations" do
      expect(subject.clawed_back_count).to eql(5)
    end
  end
end
