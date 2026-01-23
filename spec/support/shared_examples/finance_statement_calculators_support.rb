# frozen_string_literal: true

RSpec.shared_examples "a Finance ECF statement calculator", mid_cohort: true do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

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

  let!(:statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 1.week.ago) }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  subject { described_class.new(statement:) }

  before do
    # Mock banding calculator with mocked methods
    if defined?(mock_bandings)
      banding_calculator_klass = described_class.module_parent::BandingCalculator

      declaration_types.each do |declaration_type|
        mock_banding = instance_double(banding_calculator_klass)
        %i[count additions subtractions].each do |action|
          dec_values = mock_bandings[declaration_type] || {}
          action_values = dec_values[action] || {}

          letters.each do |letter|
            allow(mock_banding).to receive(action)
              .with(letter)
              .and_return(action_values[letter] || 0)
          end
        end

        expect(banding_calculator_klass).to receive(:new)
          .with(statement:, declaration_type:)
          .and_return(mock_banding)
      end
    end

    # Mock uplift values
    if defined?(mock_uplift)
      uplift_calculator_klass = described_class.module_parent::UpliftCalculator
      mock_uplift_double = instance_double(uplift_calculator_klass, **mock_uplift)
      allow(uplift_calculator_klass).to receive(:new).with(statement:).and_return(mock_uplift_double)
    end

    # Mock fee_for_declaration
    if defined?(mock_fee_for_declaration)
      output_calculator = subject.send(:output_calculator)
      allow(output_calculator).to receive(:fee_for_declaration).and_return(*mock_fee_for_declaration)
    end
  end

  describe "#total" do
    let(:default_total) { BigDecimal("-4932.7931") }

    let(:mock_uplift) do
      {
        count: 2,
        additions: 4,
        subtractions: 2,
      }
    end

    context "when there is a positive reconcile_amount" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "increases total" do
        expect(subject.total(with_vat: false).round(5)).to eql(default_total + 1234)
      end
    end

    context "when there is a negative reconcile_amount" do
      before do
        statement.update!(reconcile_amount: -1234)
      end

      it "descreases the total" do
        expect(subject.total(with_vat: false).round(5)).to eql(default_total - 1234)
      end
    end

    context "when VAT is applicable" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "affects the amount to reconcile by" do
        expect(subject.total(with_vat: true).round(5)).to eql((default_total + 1234) * 1.2)
      end
    end

    context "with additional adjustments" do
      let!(:adjustment1) { create :adjustment, statement:, payment_type: "Big amount", amount: 999.99 }
      let!(:adjustment2) { create :adjustment, statement:, payment_type: "Negative amount", amount: -500.0 }
      let!(:adjustment3) { create :adjustment, statement:, payment_type: "Another amount", amount: 300.0 }

      it "returns correct value" do
        expect(subject.statement.adjustments.count).to eql(3)
        expect(subject.additional_adjustments_total).to eql(799.99)
        expect(subject.total(with_vat: true).round(5)).to eql((default_total + 799.99) * 1.2)
      end
    end

    context "when contract does not include uplift fees" do
      before { allow_any_instance_of(CallOffContract).to receive(:include_uplift_fees?).and_return(false) }

      it "returns default total with no uplifts" do
        expect(subject.total.round(5)).to eql(default_total - 200)
      end
    end
  end

  describe "#output_fee" do
    context "with extended" do
      let(:mock_bandings) do
        {
          "extended-1" => {
            additions:  {
              a: 1,
              b: 4,
            },
          },
          "extended-2" => {
            additions:  {
              a: 2,
              b: 5,
            },
          },
          "extended-3" => {
            additions:  {
              a: 3,
              b: 6,
            },
          },
        }
      end
      let(:mock_fee_for_declaration) { 48 }

      it "returns correct value across all bands" do
        output_fee =
          ((1 * 48) + (4 * 48)) +
          ((2 * 48) + (5 * 48)) +
          ((3 * 48) + (6 * 48))
        expect(subject.output_fee).to eql(output_fee)
      end
    end
  end

  describe "#clawback_deductions" do
    context "with extended" do
      let(:mock_bandings) do
        {
          "extended-1" => {
            subtractions:  {
              a: 1,
              b: 4,
            },
          },
          "extended-2" => {
            subtractions:  {
              a: 2,
              b: 5,
            },
          },
          "extended-3" => {
            subtractions:  {
              a: 3,
              b: 6,
            },
          },
        }
      end

      let(:mock_fee_for_declaration) { 48 }

      it "returns correct value across all bands" do
        deductions =
          ((1 * 48) + (4 * 48)) +
          ((2 * 48) + (5 * 48)) +
          ((3 * 48) + (6 * 48))
        expect(subject.clawback_deductions).to eql(deductions)
      end
    end
  end

  describe "#adjustments_total" do
    context "when there are uplifts" do
      let(:mock_uplift) do
        {
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end

      let!(:contract) { create(:call_off_contract, lead_provider:) }

      it "includes uplift adjustments" do
        expect(subject.adjustments_total).to eql(-200)
      end

      context "when contract does not include uplift fees" do
        before { allow_any_instance_of(CallOffContract).to receive(:include_uplift_fees?).and_return(false) }

        it "returns zero" do
          expect(subject.adjustments_total).to be_zero
        end
      end
    end

    context "when there are clawbacks" do
      let(:mock_uplift) do
        {
          count: 0,
          additions: 0,
          subtractions: 0,
        }
      end

      let(:mock_bandings) do
        {
          "started" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-1" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-2" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-3" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-4" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "completed" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
        }
      end
      let(:mock_fee_for_declaration) { 48 }

      it "includes clawback adjustments" do
        expect(subject.adjustments_total).to eql(-288)
      end
    end

    context "when there are uplifts and clawbacks" do
      let(:mock_uplift) do
        {
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end

      let(:mock_bandings) do
        {
          "started" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-1" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-2" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-3" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "retained-4" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
          "completed" => {
            previous_count: { a: 1, b: 0 },
            count:          { a: 1, b: 1 },
            additions:      { a: 1, b: 2 },
            subtractions:   { a: 0, b: 1 },
          },
        }
      end

      let!(:contract) { create(:call_off_contract, lead_provider:) }
      let(:mock_fee_for_declaration) { 48 }

      it "includes clawback and uplift adjustments" do
        expect(subject.adjustments_total).to eql(-488)
      end

      context "when contract does not include uplift fees" do
        before { allow_any_instance_of(CallOffContract).to receive(:include_uplift_fees?).and_return(false) }

        it "includes clawback adjustments only" do
          expect(subject.adjustments_total).to eq(-288)
        end
      end
    end
  end

  describe "#additional_adjustments_total" do
    context "no adjustments" do
      it "returns correct value" do
        expect(subject.statement.adjustments.count).to eql(0)
        expect(subject.additional_adjustments_total).to eql(0.0)
      end
    end

    context "one adjustment" do
      let!(:adjustment) { create :adjustment, statement:, payment_type: "Big amount", amount: 999.99 }

      it "returns correct value" do
        expect(subject.statement.adjustments.count).to eql(1)
        expect(subject.additional_adjustments_total).to eql(999.99)
      end
    end

    context "multiple adjustments" do
      let!(:adjustment1) { create :adjustment, statement:, payment_type: "Big amount", amount: 999.99 }
      let!(:adjustment2) { create :adjustment, statement:, payment_type: "Negative amount", amount: -500.0 }
      let!(:adjustment3) { create :adjustment, statement:, payment_type: "Another amount", amount: 300.0 }

      it "returns correct value" do
        expect(subject.statement.adjustments.count).to eql(3)
        expect(subject.additional_adjustments_total).to eql(799.99)
      end
    end
  end

  describe "#additions_for_started" do
    let(:mock_bandings) do
      {
        "started" => {
          previous_count: { a: 1, b: 0 },
          count:          { a: 1, b: 1 },
          additions:      { a: 1, b: 2 },
          subtractions:   { a: 0, b: 1 },
        },
      }
    end
    let(:mock_fee_for_declaration) { [48, 36, 36] }

    it "returns correct value across all bands" do
      expect(subject.additions_for_started).to eql(48 + 36 + 36)
    end
  end

  describe "#additions_for_extended" do
    let(:mock_bandings) do
      {
        "extended-1" => {
          additions: { a: 1, b: 4 },
        },
        "extended-2" => {
          additions: { a: 2, b: 5 },
        },
        "extended-3" => {
          additions: { a: 3, b: 6 },
        },
      }
    end
    let(:mock_fee_for_declaration) { 48 }

    it "returns correct value across all bands" do
      expect(subject.additions_for_extended_1).to eql((1 * 48) + (4 * 48)) # = 240
      expect(subject.additions_for_extended_2).to eql((2 * 48) + (5 * 48)) # = 336
      expect(subject.additions_for_extended_3).to eql((3 * 48) + (6 * 48)) # = 432
      expect(subject.additions_for_extended).to eql(240 + 336 + 432)
    end
  end

  describe "#total_for_uplift" do
    context "when there are no uplifts" do
      it "returns zero" do
        expect(subject.total_for_uplift).to be_zero
      end
    end

    context "when there are uplifts" do
      let(:mock_uplift) do
        {
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end

      let!(:contract) { create(:call_off_contract, lead_provider:) }

      it do
        expect(subject.total_for_uplift).to eql(400)
      end
    end

    context "when there is net negative uplifts" do
      let(:mock_uplift) do
        {
          count: -3,
          additions: 1,
          subtractions: 4,
        }
      end

      it do
        expect(subject.total_for_uplift).to eql(100)
      end
    end

    context "when contract does not include uplift fees" do
      let(:mock_uplift) do
        {
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end

      before do
        allow_any_instance_of(CallOffContract).to receive(:include_uplift_fees?).and_return(false)
      end

      it "returns zero" do
        expect(subject.total_for_uplift).to be_zero
      end
    end
  end

  describe "#uplift_fee_per_declaration" do
    it do
      expect(subject.uplift_fee_per_declaration).to eql(100)
    end

    context "when contract does not include uplift fees" do
      before { allow_any_instance_of(CallOffContract).to receive(:include_uplift_fees?).and_return(false) }

      it "returns zero" do
        expect(subject.uplift_fee_per_declaration).to be_zero
      end
    end
  end

  describe "#started_count" do
    let(:mock_bandings) do
      {
        "started" => {
          previous_count: { a: 1, b: 0 },
          count:          { a: 1, b: 1 },
          additions:      { a: 1, b: 2 },
          subtractions:   { a: 0, b: 1 },
        },
      }
    end

    it "returns count of all started across bands" do
      expect(subject.started_count).to eql(3)
    end
  end

  describe "#retained_count" do
    let(:mock_bandings) do
      {
        "retained-1" => {
          previous_count: { a: 1, b: 0 },
          count:          { a: 1, b: 1 },
          additions:      { a: 1, b: 2 },
          subtractions:   { a: 0, b: 1 },
        },
        "retained-2" => {
          previous_count: { a: 1, b: 0 },
          count:          { a: 1, b: 1 },
          additions:      { a: 1, b: 2 },
          subtractions:   { a: 0, b: 1 },
        },
      }
    end

    it "returns count of all retained across bands" do
      expect(subject.retained_count).to eql(6)
    end
  end

  describe "#completed_count" do
    let(:mock_bandings) do
      {
        "completed" => {
          previous_count:  {
            a: 1,
            b: 0,
          },
          count:  {
            a: 1,
            b: 1,
          },
          additions:  {
            a: 1,
            b: 2,
          },
          subtractions:  {
            a: 0,
            b: 1,
          },
        },
      }
    end

    it "returns count of all completed across bands" do
      expect(subject.completed_count).to eql(3)
    end
  end

  describe "#extended_count" do
    let(:mock_bandings) do
      {
        "extended-1" => {
          previous_count:  {
            a: 1,
            b: 0,
          },
          count:  {
            a: 1,
            b: 1,
          },
          additions:  {
            a: 1,
            b: 2,
          },
          subtractions:  {
            a: 0,
            b: 1,
          },
        },
        "extended-2" => {
          previous_count:  {
            a: 1,
            b: 0,
          },
          count:  {
            a: 1,
            b: 1,
          },
          additions:  {
            a: 1,
            b: 2,
          },
          subtractions:  {
            a: 0,
            b: 1,
          },
        },
      }
    end

    it "returns count of all extended across bands" do
      expect(subject.extended_count).to eql(6)
    end
  end

  describe "#uplift_count" do
    context "when uplift is not applicable" do
      before do
        travel_to statement.deadline_date do
          create(:ect_participant_declaration, :eligible, cpd_lead_provider:)
        end
      end

      it "does not count it" do
        expect(subject.uplift_count).to be_zero
      end
    end

    context "when uplift is applicable" do
      before do
        travel_to statement.deadline_date do
          create(:ect_participant_declaration, :eligible, uplifts: [:pupil_premium_uplift], cpd_lead_provider:)
        end
      end

      it "does count it" do
        expect(subject.uplift_count).to eql(1)
      end
    end
  end

  describe "#uplift_payment" do
    before do
      statement.contract.update!(uplift_amount: 100.0)
      travel_to statement.deadline_date do
        create_list(:ect_participant_declaration, 3, :eligible, uplifts: [:pupil_premium_uplift], cpd_lead_provider:)
      end
    end

    it "returns correct payment" do
      expect(subject.uplift_payment.to_f).to eql(300.0)
    end
  end

  describe "#service_fee" do
    let(:contract) { create(:call_off_contract, lead_provider:) }

    it "returns calculated calculated service fee" do
      expect(subject.service_fee.round(5)).to eql(BigDecimal("0.7594306897e5"))
    end

    context "when monthly_service_fee is set on contract" do
      let(:contract) { create(:call_off_contract, :with_monthly_service_fee, lead_provider:) }

      it "uses monthly_service_fee" do
        expect(subject.service_fee).to eql(123.45)
      end
    end
  end

  describe "#event_types_for_display" do
    context "when no extended declarations" do
      before do
        allow(subject).to receive(:extended_count).and_return(0)
      end

      it "should not included extended" do
        expect(subject.event_types_for_display).to eql(
          %i[
            started
            retained_1
            retained_2
            retained_3
            retained_4
            completed
          ],
        )
      end
    end

    context "when there is extended declarations" do
      before do
        allow(subject).to receive(:extended_count).and_return(99)
      end

      it "should include extended" do
        expect(subject.event_types_for_display).to eql(
          %i[
            started
            retained_1
            retained_2
            retained_3
            retained_4
            completed
            extended
          ],
        )
      end
    end
  end

  describe "#clawbacks_breakdown" do
    let(:mock_bandings) do
      {
        "started" => {
          subtractions:  {
            a: 1,
            b: 10,
          },
        },
        "retained-1" => {
          subtractions:  {
            a: 2,
            b: 11,
          },
        },
        "retained-2" => {
          subtractions:  {
            a: 3,
            b: 12,
          },
        },
        "retained-3" => {
          subtractions:  {
            a: 4,
            b: 13,
          },
        },
        "retained-4" => {
          subtractions:  {
            a: 5,
            b: 14,
          },
        },
        "completed" => {
          subtractions:  {
            a: 6,
            b: 15,
          },
        },
        "extended-1" => {
          subtractions:  {
            a: 7,
            b: 16,
          },
        },
        "extended-2" => {
          subtractions:  {
            a: 8,
            b: 17,
          },
        },
        "extended-3" => {
          subtractions:  {
            a: 9,
            b: 18,
          },
        },
      }
    end
    let(:mock_fee_for_declaration) { 100.0 }

    before do
      allow(subject).to receive(:band_letters).and_return(%i[a b])
    end

    it "returns clawbacks breakdown" do
      expect(subject.clawbacks_breakdown).to eq([
        { band: "A", count: 1, declaration_type: "Started", fee: -100.0, subtotal: -100.0 },
        { band: "A", count: 2, declaration_type: "Retained 1", fee: -100.0, subtotal: -200.0 },
        { band: "A", count: 3, declaration_type: "Retained 2", fee: -100.0, subtotal: -300.0 },
        { band: "A", count: 4, declaration_type: "Retained 3", fee: -100.0, subtotal: -400.0 },
        { band: "A", count: 5, declaration_type: "Retained 4", fee: -100.0, subtotal: -500.0 },
        { band: "A", count: 6, declaration_type: "Completed", fee: -100.0, subtotal: -600.0 },
        { band: "A", count: 7, declaration_type: "Extended 1", fee: -100.0, subtotal: -700.0 },
        { band: "A", count: 8, declaration_type: "Extended 2", fee: -100.0, subtotal: -800.0 },
        { band: "A", count: 9, declaration_type: "Extended 3", fee: -100.0, subtotal: -900.0 },

        { band: "B", count: 10, declaration_type: "Started", fee: -100.0, subtotal: -1000.0 },
        { band: "B", count: 11, declaration_type: "Retained 1", fee: -100.0, subtotal: -1100.0 },
        { band: "B", count: 12, declaration_type: "Retained 2", fee: -100.0, subtotal: -1200.0 },
        { band: "B", count: 13, declaration_type: "Retained 3", fee: -100.0, subtotal: -1300.0 },
        { band: "B", count: 14, declaration_type: "Retained 4", fee: -100.0, subtotal: -1400.0 },
        { band: "B", count: 15, declaration_type: "Completed", fee: -100.0, subtotal: -1500.0 },
        { band: "B", count: 16, declaration_type: "Extended 1", fee: -100.0, subtotal: -1600.0 },
        { band: "B", count: 17, declaration_type: "Extended 2", fee: -100.0, subtotal: -1700.0 },
        { band: "B", count: 18, declaration_type: "Extended 3", fee: -100.0, subtotal: -1800.0 },
      ])
    end
  end
end
