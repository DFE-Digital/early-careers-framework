# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPaid, :with_default_schedules do
  describe "#perform" do
    let!(:declaration) { create(:ect_participant_declaration, :payable) }

    it "updates the declaration state" do
      expect(declaration).to be_payable
      expect(declaration).not_to be_paid
      described_class.call
      declaration.reload
      expect(declaration).not_to be_payable
      expect(declaration).to be_paid
    end
  end
end
