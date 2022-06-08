# frozen_string_literal: true

RSpec.describe Finance::ECF::StatementCalculator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let!(:statement) { create(:ecf_statement, cpd_lead_provider:, deadline_date: 1.week.ago) }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  subject { described_class.new(statement:) }

  describe "#started_band_a_count" do
    context "when there are no declarations" do
      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end
    end

    context "when there are declarations attached to another statement for different provider" do
      let(:other_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:other_lead_provider) { other_cpd_lead_provider.lead_provider }

      let!(:other_statement) { create(:ecf_statement, cpd_lead_provider: other_cpd_lead_provider, deadline_date: 1.week.ago) }
      let!(:other_contract) { create(:call_off_contract, :with_minimal_bands, lead_provider: other_lead_provider) }

      before do
        declarations = create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider: other_cpd_lead_provider,
          state: "eligible"
        )

        declarations.each do |declaration|
          Finance::StatementLineItem.create!(
            statement: other_statement,
            participant_declaration: declaration,
            state: declaration.state,
          )
        end
      end

      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end
    end

    context "when band is partially populated" do
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

      it "returns the number of declarations" do
        expect(subject.started_band_a_count).to eql(1)
      end
    end

    context "when the band had overflowed" do
      before do
        declarations = create_list(
          :ect_participant_declaration, 3,
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

      it "returns the maximum number allowed in the band" do
        expect(subject.started_band_a_count).to eql(2)
      end
    end

    context "when there is a previous statement partially filling the band" do
      let!(:previous_statement) { create(:ecf_statement, cpd_lead_provider:, deadline_date: 5.weeks.ago) }

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
      let!(:previous_statement) { create(:ecf_statement, cpd_lead_provider:, deadline_date: 5.weeks.ago) }

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
      let(:profile) { create(:ect_participant_profile) }

      before do
        declaration = create(
        :ect_participant_declaration, :without_uplift,
          cpd_lead_provider:,
          state: "eligible",
          participant_profile: profile
        )

        Finance::StatementLineItem.create!(
          statement:,
          participant_declaration: declaration,
          state: declaration.state,
        )
      end

      it "does not count it" do
        expect(subject.uplift_count).to be_zero
      end
    end

    context "when uplift is applicable" do
      let(:profile) { create(:ect_participant_profile) }
      let(:declaration) do
        create(
          :ect_participant_declaration, :pupil_premium_uplift,
          cpd_lead_provider:,
          state: "eligible",
          participant_profile: profile
        )
      end

      before do
        Finance::StatementLineItem.create!(
          statement:,
          participant_declaration: declaration,
          state: declaration.state,
        )
      end

      it "does count it" do
        expect(subject.uplift_count).to eql(1)
      end
    end
  end
end
