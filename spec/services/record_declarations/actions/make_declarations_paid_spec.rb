# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Actions::MakeDeclarationsPaid do
  describe "#call" do
    before { create(:ect_participant_declaration, :payable) }

    context "with a ParticipantDeclaration::ECF type" do
      it "updates the declaration state" do
        expect(declaration).to be_payable
        expect(declaration).not_to be_paid
        described_class.call(declaration_class: ParticipantDeclaration::ECF)
        declaration.reload
        expect(declaration).not_to be_payable
        expect(declaration).to be_paid
      end
    end

    context "with a ParticipantDeclaration::NPQ type" do

    end
  end
end
