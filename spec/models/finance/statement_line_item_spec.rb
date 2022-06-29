# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::StatementLineItem do
  let(:statement) { create(:ecf_statement) }
  let(:declaration) { create(:ect_participant_declaration, :eligible) }

  describe "validations" do
    context "when already billied to a statement" do
      let!(:existing_line_item) do
        described_class.create!(
          statement:,
          participant_declaration: declaration,
          state: declaration.state,
        )
      end

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
      let(:declaration) { create(:ect_participant_declaration, :awaiting_clawback) }

      let!(:existing_line_item) do
        described_class.create!(
          statement:,
          participant_declaration: declaration,
          state: declaration.state,
        )
      end

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
