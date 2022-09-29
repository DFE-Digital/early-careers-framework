# frozen_string_literal: true

RSpec.describe Finance::ECF::StatementCalculator, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let!(:statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 1.week.ago) }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  subject { described_class.new(statement:) }

  describe "#total" do
    let(:default_total) { BigDecimal("-0.5132793103448275862068965517241379310345e4") }

    context "when there is a positive reconcile_amount" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "increases total" do
        expect(subject.total(with_vat: false)).to eql(default_total + 1234)
      end
    end

    context "when there is a negative reconcile_amount" do
      before do
        statement.update!(reconcile_amount: -1234)
      end

      it "descreases the total" do
        expect(subject.total(with_vat: false)).to eql(default_total - 1234)
      end
    end

    context "when VAT is applicable" do
      before do
        statement.update!(reconcile_amount: 1234)
      end

      it "affects the amount to reconcile by" do
        expect(subject.total(with_vat: true)).to eql((default_total + 1234) * 1.2)
      end
    end
  end

  describe "#adjustments_total" do
    context "when there are uplifts" do
      let(:uplift_breakdown) do
        {
          previous_count: 0,
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end

      let(:banding_breakdown) do
        []
      end

      let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", uplift_breakdown:, banding_breakdown:) }

      let!(:contract) { create(:call_off_contract, lead_provider:) }

      before do
        allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
      end

      it "includes uplift adjustments" do
        expect(subject.adjustments_total).to eql(200)
      end
    end

    context "when there are clawbacks" do
      let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", banding_breakdown:, uplift_breakdown:) }

      let(:uplift_breakdown) do
        {
          previous_count: 0,
          count: 0,
          additions: 0,
          subtractions: 0,
        }
      end

      let(:banding_breakdown) do
        [
          {
            band: :a,
            min: 1,
            max: 2,

            previous_started_count: 1,
            started_count: 1,
            started_additions: 1,
            started_subtractions: 0,

            previous_retained_1_count: 1,
            retained_1_count: 1,
            retained_1_additions: 1,
            retained_1_subtractions: 0,

            previous_retained_2_count: 1,
            retained_2_count: 1,
            retained_2_additions: 1,
            retained_2_subtractions: 0,

            previous_retained_3_count: 1,
            retained_3_count: 1,
            retained_3_additions: 1,
            retained_3_subtractions: 0,

            previous_retained_4_count: 1,
            retained_4_count: 1,
            retained_4_additions: 1,
            retained_4_subtractions: 0,

            previous_completed_count: 1,
            completed_count: 1,
            completed_additions: 1,
            completed_subtractions: 0,
          },
          {
            band: :b,
            min: 3,
            max: 4,

            previous_started_count: 0,
            started_count: 1,
            started_additions: 2,
            started_subtractions: 1,

            previous_retained_1_count: 0,
            retained_1_count: 1,
            retained_1_additions: 2,
            retained_1_subtractions: 1,

            previous_retained_2_count: 0,
            retained_2_count: 1,
            retained_2_additions: 2,
            retained_2_subtractions: 1,

            previous_retained_3_count: 0,
            retained_3_count: 1,
            retained_3_additions: 2,
            retained_3_subtractions: 1,

            previous_retained_4_count: 0,
            retained_4_count: 1,
            retained_4_additions: 2,
            retained_4_subtractions: 1,

            previous_completed_count: 0,
            completed_count: 1,
            completed_additions: 2,
            completed_subtractions: 1,
          },
        ]
      end

      before do
        allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
        allow(output_calculator).to receive(:fee_for_declaration).and_return(48)
      end

      it "includes clawback adjustments" do
        expect(subject.adjustments_total).to eql(-288)
      end
    end
  end

  describe "#additions_for_started" do
    let(:banding_breakdown) do
      [
        {
          band: :a,
          min: 1,
          max: 2,
          previous_started_count: 1,
          started_count: 1,
          started_additions: 1,
          started_subtractions: 0,
        },
        {
          band: :b,
          min: 3,
          max: 4,
          previous_started_count: 0,
          started_count: 1,
          started_additions: 2,
          started_subtractions: 1,
        },
      ]
    end

    let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator") }

    before do
      allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)

      allow(output_calculator).to receive(:banding_breakdown).and_return(banding_breakdown)

      allow(output_calculator).to receive(:fee_for_declaration).and_return(48, 36, 36)
    end

    it "returns correct value across all bands" do
      expect(subject.additions_for_started).to eql(48 + 36 + 36)
    end
  end

  describe "#total_for_uplift" do
    context "when there are no uplifts" do
      it "returns zero" do
        expect(subject.total_for_uplift).to be_zero
      end
    end

    context "when there are uplifts" do
      let(:uplift_breakdown) do
        {
          previous_count: 5,
          count: 2,
          additions: 4,
          subtractions: 2,
        }
      end

      let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", uplift_breakdown:) }

      let!(:contract) { create(:call_off_contract, lead_provider:) }

      before do
        allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
      end

      it do
        expect(subject.total_for_uplift).to eql(200)
      end
    end

    context "when there is net negative uplifts" do
      let(:uplift_breakdown) do
        {
          previous_count: 5,
          count: -3,
          additions: 1,
          subtractions: 4,
        }
      end

      let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", uplift_breakdown:) }

      before do
        allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
      end

      it do
        expect(subject.total_for_uplift).to eql(-300)
      end
    end

    context "when we pass the uplift cap threshold" do
      let!(:contract) { create(:call_off_contract, lead_provider: cpd_lead_provider.lead_provider) }

      let(:uplift_breakdown) do
        {
          previous_count: 0,
          count: 100_000,
          additions: 100_000,
          subtractions: 0,
        }
      end

      let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", uplift_breakdown:) }

      before do
        allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
      end

      it "matches uplift_cap" do
        expect(subject.total_for_uplift).to eql(statement.contract.uplift_cap)
      end
    end
  end

  describe "#uplift_fee_per_declaration" do
    it do
      expect(subject.uplift_fee_per_declaration).to eql(100)
    end
  end

  describe "#started_count" do
    let(:banding_breakdown) do
      [
        {
          band: :a,
          min: 1,
          max: 2,
          previous_started_count: 1,
          started_count: 1,
          started_additions: 1,
          started_subtractions: 0,
        },
        {
          band: :b,
          min: 3,
          max: 4,
          previous_started_count: 0,
          started_count: 1,
          started_additions: 2,
          started_subtractions: 1,
        },
      ]
    end
    let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", banding_breakdown:) }

    before do
      allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
    end

    it "returns count of all started across bands" do
      expect(subject.started_count).to eql(3)
    end
  end

  describe "#retained_count" do
    let(:banding_breakdown) do
      [
        {
          band: :a,
          min: 1,
          max: 2,
          previous_retained_1_count: 1,
          retained_1_count: 1,
          retained_1_additions: 1,
          retained_1_subtractions: 0,
          previous_started_count: 1,
          retained_2_count: 1,
          retained_2_additions: 1,
          retained_2_subtractions: 0,
        },
        {
          band: :b,
          min: 3,
          max: 4,
          previous_retained_1_count: 0,
          retained_1_count: 1,
          retained_1_additions: 2,
          retained_1_subtractions: 1,
          previous_retained_2_count: 0,
          retained_2_count: 1,
          retained_2_additions: 2,
          retained_2_subtractions: 1,
        },
      ]
    end
    let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", banding_breakdown:) }

    before do
      allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
    end

    it "returns count of all retained across bands" do
      expect(subject.retained_count).to eql(6)
    end
  end

  describe "#completed_count" do
    let(:banding_breakdown) do
      [
        {
          band: :a,
          min: 1,
          max: 2,
          previous_completed_count: 1,
          completed_count: 1,
          completed_additions: 1,
          completed_subtractions: 0,
        },
        {
          band: :b,
          min: 3,
          max: 4,
          previous_completed_count: 0,
          completed_count: 1,
          completed_additions: 2,
          completed_subtractions: 1,
        },
      ]
    end
    let(:output_calculator) { instance_double("Finance::ECF::OutputCalculator", banding_breakdown:) }

    before do
      allow(Finance::ECF::OutputCalculator).to receive(:new).and_return(output_calculator)
    end

    it "returns count of all completed across bands" do
      expect(subject.completed_count).to eql(3)
    end
  end

  describe "#started_band_a_count" do
    context "when there are no declarations" do
      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end
    end

    context "when there are declarations attached to another statement for different provider" do
      let(:other_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }

      let!(:other_statement) { create(:ecf_statement, cpd_lead_provider: other_cpd_lead_provider, payment_date: 1.week.ago) }

      before do
        create(:call_off_contract, :with_minimal_bands, lead_provider: other_cpd_lead_provider.lead_provider)

        travel_to other_statement.deadline_date - 1.day do
          create(:ect_participant_declaration, :eligible, cpd_lead_provider: other_cpd_lead_provider)
        end
      end

      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end
    end

    context "when band is partially populated" do
      before do
        travel_to statement.deadline_date do
          create(:ect_participant_declaration, :eligible, cpd_lead_provider:)
        end
      end

      it "returns the number of declarations" do
        expect(subject.started_band_a_count).to eql(1)
      end
    end

    context "when the band had overflowed" do
      before do
        travel_to statement.deadline_date - 1.day do
          create_list(:ect_participant_declaration, 3, :eligible, cpd_lead_provider:)
        end
      end

      it "returns the maximum number allowed in the band" do
        expect(subject.started_band_a_count).to eq(2)
      end
    end

    context "when there is a previous statement partially filling the band" do
      let!(:previous_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 5.weeks.ago) }

      before do
        declarations = create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider:,
          state: "eligible"
        )

        declarations.each do |declaration|
          Finance::StatementLineItem.create!(
            statement: previous_statement,
            participant_declaration: declaration,
            state: declaration.state,
          )
        end
      end

      context "there are no declarations on this statement" do
        it "returns zero" do
          expect(subject.started_band_a_count).to be_zero
        end
      end

      context "there are declarations on this statement, partly filling it" do
        before do
          declarations = create_list(
            :ect_participant_declaration, 1,
            cpd_lead_provider:,
            state: "eligible"
          )

          declarations.each do |declaration|
            Finance::StatementLineItem.create!(
              statement:,
              participant_declaration: declaration,
              state: declaration.state,
            )
          end
        end

        it "returns number of permitted declarations" do
          expect(subject.started_band_a_count).to eql(1)
        end
      end

      context "there are declarations on this statement, over filling it" do
        before do
          declarations = create_list(
            :ect_participant_declaration, 2,
            cpd_lead_provider:,
            state: "eligible"
          )

          declarations.each do |declaration|
            Finance::StatementLineItem.create!(
              statement:,
              participant_declaration: declaration,
              state: declaration.state,
            )
          end
        end

        it "returns max number of permitted declarations" do
          expect(subject.started_band_a_count).to eql(1)
        end
      end
    end

    context "when there is a previous statement totally filling the band" do
      let!(:previous_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 5.weeks.ago) }

      before do
        declarations = create_list(
          :ect_participant_declaration, 2,
          cpd_lead_provider:,
          state: "eligible"
        )

        declarations.each do |declaration|
          Finance::StatementLineItem.create!(
            statement: previous_statement,
            participant_declaration: declaration,
            state: declaration.state,
          )
        end

        declarations = create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider:,
          state: "eligible"
        )

        declarations.each do |declaration|
          Finance::StatementLineItem.create!(
            statement:,
            participant_declaration: declaration,
            state: declaration.state,
          )
        end
      end

      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end

      it "returns declaration in next band" do
        expect(subject.started_band_b_count).to eql(1)
      end
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

    context "paid declaration transitions to awaiting_clawback" do
      let(:old_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 2.months.ago) }
      let(:new_statement) { create(:ecf_statement, cpd_lead_provider:, payment_date: 2.months.from_now) }

      let(:declaration) do
        create(
          :ect_participant_declaration,
          cpd_lead_provider:,
          state: "paid",
        )
      end

      before do
        Finance::StatementLineItem.create!(
          participant_declaration: declaration,
          statement: old_statement,
          state: declaration.state,
        )

        Finance::StatementLineItem.create!(
          participant_declaration: declaration,
          statement: new_statement,
          state: "awaiting_clawback",
        )
      end

      describe "#started_band_a_count" do
        context "for old statement" do
          subject { described_class.new(statement: old_statement) }

          it "continues to count declaration" do
            expect(subject.started_band_a_count).to eql(1)
          end
        end

        context "for new statement" do
          subject { described_class.new(statement: new_statement) }

          it "counts the declaration" do
            expect(subject.started_band_a_count).to eql(-1)
          end
        end
      end
    end
  end

  describe "#service_fee" do
    let(:contract) { create(:call_off_contract, lead_provider:) }

    it "returns calculated calculated service fee" do
      expect(subject.service_fee).to eql(BigDecimal("0.75943068965517241379310344827586206896551e5"))
    end

    context "when monthly_service_fee is set on contract" do
      let(:contract) { create(:call_off_contract, :with_monthly_service_fee, lead_provider:) }

      it "uses monthly_service_fee" do
        expect(subject.service_fee).to eql(123.45)
      end
    end
  end
end
