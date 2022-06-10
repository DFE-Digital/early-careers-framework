# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::StatementLineItem, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let!(:statement)        { create(:ecf_statement, :next_output_fee, cpd_lead_provider:) }

  describe "validations" do
    context "when already billed to a statement" do
      let!(:declaration) { create(:ect_participant_declaration, :eligible, cpd_lead_provider:) }

      it "cannot be billed to multiple statements" do
        expect {
          described_class.create(
            statement:,
            participant_declaration: declaration,
            state: declaration.state,
          )
        }.not_to change(Finance::StatementLineItem, :count)
      end
    end

    context "when already refunded to a statement" do
      let!(:declaration) { create(:ect_participant_declaration, :awaiting_clawback, cpd_lead_provider:) }

      it "cannot be refunded to multiple statements" do
        expect {
          described_class.create(
            statement:,
            participant_declaration: declaration,
            state: declaration.state,
          )
        }.not_to change(Finance::StatementLineItem, :count)
      end
    end
  end
end
