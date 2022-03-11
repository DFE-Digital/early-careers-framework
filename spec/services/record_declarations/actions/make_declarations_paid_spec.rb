# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPaid do
  describe "#perform" do
    let!(:declaration) { create(:ect_participant_declaration, :payable) }

    it "updates the declaration state" do
      expect(declaration.payable?).to be_truthy
      expect(declaration.paid?).to be_falsey
      described_class.call
      declaration.reload
      expect(declaration.payable?).to be_falsey
      expect(declaration.paid?).to be_truthy
    end
  end
end
