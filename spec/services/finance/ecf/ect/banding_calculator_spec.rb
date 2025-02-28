# frozen_string_literal: true

RSpec.describe Finance::ECF::ECT::BandingCalculator do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let!(:call_off_contract) { create(:call_off_contract, :with_minimal_bands, lead_provider:) }

  let!(:statement) { create(:ecf_statement, :output_fee, cpd_lead_provider:) }
  let(:statement_one_month_ago) { create(:ecf_statement, :one_month_ago, cpd_lead_provider:) }
  let(:statement_two_months_ago) { create(:ecf_statement, :two_months_ago, cpd_lead_provider:) }
  let(:declaration_type) { "started" }

  subject { described_class.new(statement:, declaration_type:) }

  describe "#previous_billable_count" do
    before do
      travel_to statement_one_month_ago.deadline_date - 1.day do
        create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
      end
      travel_to statement.deadline_date - 1.day do
        create_list(:ect_participant_declaration, 3, :eligible, cpd_lead_provider:, declaration_type:)
        create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
      end
    end

    it "returns ECT only previous billable count for this months statement" do
      expect(subject.send(:previous_billable_count)).to eq(2)
    end
  end

  describe "#previous_refundable_count" do
    before do
      # Create declarations for statement 2 months ago
      declarations = []
      travel_to statement_two_months_ago.deadline_date - 1.day do
        declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
      end

      # Mark statement 2 months ago as paid
      Statements::MarkAsPayable.new(statement_two_months_ago).call
      Statements::MarkAsPaid.new(statement_two_months_ago).call

      # Create clawbacks for statement 1 month ago from declarations 2 months ago
      travel_to statement_one_month_ago.deadline_date - 1.day do
        declarations.each do |dec|
          Finance::ClawbackDeclaration.new(dec.reload).call
        end
      end
      # Mark statement 1 months ago as paid
      Statements::MarkAsPayable.new(statement_one_month_ago).call
      Statements::MarkAsPaid.new(statement_one_month_ago).call

      travel_to statement.deadline_date - 1.day do
        # Create declarations for this month statement
        create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
        create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
      end
    end

    it "returns ECT only previous refundable count for this months statement" do
      expect(subject.send(:previous_refundable_count)).to eq(2)
    end
  end

  describe "#current_billable_count" do
    before do
      travel_to statement_one_month_ago.deadline_date - 1.day do
        create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
      end
      travel_to statement.deadline_date - 1.day do
        create_list(:ect_participant_declaration, 3, :eligible, cpd_lead_provider:, declaration_type:)
        create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
      end
    end

    it "returns ECT only current billable count for this months statement" do
      expect(subject.send(:current_billable_count)).to eq(3)
    end
  end

  describe "#current_refundable_count" do
    before do
      # Create declarations for statement 2 months ago
      declarations = []
      travel_to statement_two_months_ago.deadline_date - 1.day do
        declarations += create_list(:ect_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
        declarations += create_list(:mentor_participant_declaration, 2, :eligible, cpd_lead_provider:, declaration_type:)
      end

      # Mark statement 2 months ago as paid
      Statements::MarkAsPayable.new(statement_two_months_ago).call
      Statements::MarkAsPaid.new(statement_two_months_ago).call

      # Create clawbacks for statement 1 month ago from declarations 2 months ago
      travel_to statement_one_month_ago.deadline_date - 1.day do
        declarations.each do |dec|
          Finance::ClawbackDeclaration.new(dec.reload).call
        end
      end

      # Create declarations for statement 1 month ago
      declarations = []
      travel_to statement_one_month_ago.deadline_date - 1.day do
        declarations += create_list(:ect_participant_declaration, 3, :eligible, cpd_lead_provider:, declaration_type:)
        declarations += create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
      end

      # Mark statement 1 months ago as paid
      Statements::MarkAsPayable.new(statement_one_month_ago).call
      Statements::MarkAsPaid.new(statement_one_month_ago).call

      travel_to statement.deadline_date - 1.day do
        # Create declarations for this month statement
        create_list(:ect_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)
        create_list(:mentor_participant_declaration, 1, :eligible, cpd_lead_provider:, declaration_type:)

        # Create clawbacks for this month statement from declarations 1 month ago
        declarations.each do |dec|
          Finance::ClawbackDeclaration.new(dec.reload).call
        end
      end
    end

    it "returns ECT only current refundable count for this months statement" do
      expect(subject.send(:current_refundable_count)).to eq(3)
    end
  end
end
