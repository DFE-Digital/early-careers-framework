# frozen_string_literal: true

RSpec.describe Finance::ECF::StatementCalculator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let!(:statement) { create(:ecf_statement, cpd_lead_provider: cpd_lead_provider, deadline_date: 1.week.ago) }
  let!(:contract) { create(:call_off_contract, :with_minimal_bands, lead_provider: lead_provider) }

  subject { described_class.new(statement: statement) }

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
        create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider: other_cpd_lead_provider,
          state: "eligible",
          statement: other_statement
        )
      end

      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end
    end

    context "when band is partially populated" do
      before do
        create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: statement
        )
      end

      it "returns the number of declarations" do
        expect(subject.started_band_a_count).to eql(1)
      end
    end

    context "when the band had overflowed" do
      before do
        create_list(
          :ect_participant_declaration, 3,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: statement
        )
      end

      it "returns the maximum number allowed in the band" do
        expect(subject.started_band_a_count).to eql(2)
      end
    end

    context "when there is a previous statement partially filling the band" do
      let!(:previous_statement) { create(:ecf_statement, cpd_lead_provider: cpd_lead_provider, deadline_date: 5.weeks.ago) }

      before do
        create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: previous_statement
        )
      end

      context "there are no declarations on this statement" do
        it "returns zero" do
          expect(subject.started_band_a_count).to be_zero
        end
      end

      context "there are declarations on this statement, partly filling it" do
        before do
          create_list(
            :ect_participant_declaration, 1,
            cpd_lead_provider: cpd_lead_provider,
            state: "eligible",
            statement: statement
          )
        end

        it "returns number of permitted declarations" do
          expect(subject.started_band_a_count).to eql(1)
        end
      end

      context "there are declarations on this statement, over filling it" do
        before do
          create_list(
            :ect_participant_declaration, 2,
            cpd_lead_provider: cpd_lead_provider,
            state: "eligible",
            statement: statement
          )
        end

        it "returns max number of permitted declarations" do
          expect(subject.started_band_a_count).to eql(1)
        end
      end
    end

    context "when there is a previous statement totally filling the band" do
      let!(:previous_statement) { create(:ecf_statement, cpd_lead_provider: cpd_lead_provider, deadline_date: 5.weeks.ago) }

      before do
        create_list(
          :ect_participant_declaration, 2,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: previous_statement
        )

        create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: statement
        )
      end

      it "returns zero" do
        expect(subject.started_band_a_count).to be_zero
      end

      it "returns declaration in next band" do
        expect(subject.started_band_b_count).to eql(1)
      end
    end

    context "when statement is open" do
      let!(:declaration) do
        create_list(
          :ect_participant_declaration, 1,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: nil
        )
      end

      it "considers non attached declarations" do
        expect(subject.started_band_a_count).to eql(1)
      end
    end
  end

  describe "#uplift_count" do
    context "when uplift is not applicable" do
      let(:profile) { create(:ect_participant_profile) }

      before do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: statement,
          participant_profile: profile,
        )
      end

      it "does not count it" do
        expect(subject.uplift_count).to be_zero
      end
    end

    context "when uplift is applicable" do
      let(:profile) { create(:ect_participant_profile, :uplift_flags) }

      before do
        create(
          :ect_participant_declaration,
          cpd_lead_provider: cpd_lead_provider,
          state: "eligible",
          statement: statement,
          participant_profile: profile,
        )
      end

      it "does count it" do
        expect(subject.uplift_count).to eql(1)
      end
    end
  end
end
