# frozen_string_literal: true

RSpec.describe Finance::ECF::OutputCalculator do
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
          Finance::ECF::BandingCalculator,
          previous_count: 5,
          count: 10,
          additions: 15,
          subtractions: 5,
        )

        expect(Finance::ECF::BandingCalculator).to receive(:new)
          .with(statement: first_statement, declaration_type:)
          .and_return(mock_banding)
      end
    end

    it "correctly delegates to banding calculator" do
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

  describe "#uplift" do
    before do
      mock_uplift = instance_double(
        Finance::ECF::UpliftCalculator,
        previous_count: 5,
        count: 10,
        additions: 15,
        subtractions: 5,
      )

      expect(Finance::ECF::UpliftCalculator).to receive(:new)
        .with(statement: first_statement)
        .and_return(mock_uplift)
    end

    it "correctly delegates to uplift calculator" do
      expect(subject.uplift.previous_count).to eq(5)
      expect(subject.uplift.count).to eq(10)
      expect(subject.uplift.additions).to eq(15)
      expect(subject.uplift.subtractions).to eq(5)
    end
  end
end
