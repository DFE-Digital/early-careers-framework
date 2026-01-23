# frozen_string_literal: true

RSpec.describe Finance::ECF::UpliftCalculator, mid_cohort: true do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:call_off_contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }
  let(:bands) { call_off_contract.bands }

  let!(:statement) { create(:ecf_statement, :output_fee, cpd_lead_provider:) }
  let(:statement_one_month_ago) { create(:ecf_statement, :one_month_ago, cpd_lead_provider:) }
  let(:statement_two_months_ago) { create(:ecf_statement, :two_months_ago, cpd_lead_provider:) }
  let(:declaration_type) { "started" }

  let(:calculator_one_month_ago) { described_class.new(statement: statement_one_month_ago) }
  let(:calculator_two_months_ago) { described_class.new(statement: statement_two_months_ago) }
  subject { described_class.new(statement:) }

  context "when there an no uplifts" do
    it "returns zero current uplifts" do
      expect(subject.count).to eq(0)
      expect(subject.additions).to eq(0)
      expect(subject.subtractions).to eq(0)
    end
  end

  context "when there are uplifts" do
    before do
      travel_to statement.deadline_date - 1.day do
        create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
        create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
      end
    end

    it "returns current uplifts" do
      expect(subject.count).to eq(4)
      expect(subject.additions).to eq(4)
      expect(subject.subtractions).to eq(0)
    end
  end

  context "when there are uplifts but not on started declarations" do
    let(:declaration_type) { "retained-1" }

    before do
      travel_to statement.deadline_date - 1.day do
        create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
        create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
      end
    end

    it "does not count them" do
      expect(subject.count).to eq(0)
      expect(subject.additions).to eq(0)
      expect(subject.subtractions).to eq(0)
    end
  end

  context "when previous uplifts is clawed back in this months statement" do
    before do
      declarations = []
      travel_to statement_one_month_ago.deadline_date - 1.day do
        declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
        declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
      end

      # Mark statement 1 month ago as paid
      Statements::MarkAsPayable.new(statement_one_month_ago).call
      Statements::MarkAsPaid.new(statement_one_month_ago).call

      travel_to statement.deadline_date - 1.day do
        # Create clawbacks for this month statement from declarations 1 month ago
        declarations.sample(2).each do |dec|
          Finance::ClawbackDeclaration.new(dec.reload, voided_by_user: nil).call
        end
      end
    end

    it "returns uplifts for statement one month ago" do
      expect(calculator_one_month_ago.count).to eq(4)
      expect(calculator_one_month_ago.additions).to eq(4)
      expect(calculator_one_month_ago.subtractions).to eq(0)
    end

    it "returns uplifts for this month statement" do
      expect(subject.count).to eq(-2)
      expect(subject.additions).to eq(0)
      expect(subject.subtractions).to eq(2)
    end
  end

  context "when there are uplifts for three consecutive statements" do
    let(:declarations_one_month_ago) do
      # Create declarations for statement 1 month ago
      declarations = []
      travel_to statement_one_month_ago.deadline_date - 1.day do
        declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
        declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
      end
      declarations
    end

    let(:declarations_two_months_ago) do
      # Create declarations for statement 2 months ago
      declarations = []
      travel_to statement_two_months_ago.deadline_date - 1.day do
        declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
        declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
      end
      declarations
    end

    before do
      declarations_two_months_ago
      # Mark statement 2 months ago as paid
      Statements::MarkAsPayable.new(statement_two_months_ago).call
      Statements::MarkAsPaid.new(statement_two_months_ago).call

      declarations_one_month_ago
      # Create 1 clawback for statement 1 month ago from declarations 2 months ago
      travel_to statement_one_month_ago.deadline_date - 1.day do
        Finance::ClawbackDeclaration.new(declarations_two_months_ago[0].reload, voided_by_user: nil).call
      end
      # Mark statement 1 months ago as paid
      Statements::MarkAsPayable.new(statement_one_month_ago).call
      Statements::MarkAsPaid.new(statement_one_month_ago).call

      travel_to statement.deadline_date - 1.day do
        # Create declarations for this month statement
        create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)
        create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:, pupil_premium_uplift: true)

        # Create 1 clawback for this month statement from declarations 2 months ago
        Finance::ClawbackDeclaration.new(declarations_two_months_ago[1].reload, voided_by_user: nil).call

        # Create 1 clawback for this month statement from declarations 1 month ago
        Finance::ClawbackDeclaration.new(declarations_one_month_ago[0].reload, voided_by_user: nil).call
      end
    end

    it "returns uplifts for statement two months ago" do
      expect(calculator_two_months_ago.count).to eq(4)
      expect(calculator_two_months_ago.additions).to eq(4)
      expect(calculator_two_months_ago.subtractions).to eq(0)
    end

    it "returns uplifts for statement one month ago" do
      expect(calculator_one_month_ago.count).to eq(3)
      expect(calculator_one_month_ago.additions).to eq(4)
      expect(calculator_one_month_ago.subtractions).to eq(1)
    end

    it "returns uplifts for this month statement" do
      expect(subject.count).to eq(2)
      expect(subject.additions).to eq(4)
      expect(subject.subtractions).to eq(2)
    end
  end
end
