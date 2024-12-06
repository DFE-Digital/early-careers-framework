# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ParticipantDeclarationSerializer do
  subject { described_class.new(participant_declaration) }

  describe "#serializable_hash" do
    let(:participant_declaration) { create(:ect_participant_declaration, :paid, uplifts: [:sparsity_uplift], declaration_type: "started", evidence_held: "training-event-attended") }

    it "returns correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq(participant_declaration.id)
      expect(data[:type]).to eq(:"participant-declaration")

      attrs = data[:attributes]
      expect(attrs[:participant_id]).to eq(participant_declaration.user.id)
      expect(attrs[:declaration_type]).to eq("started")
      expect(attrs[:declaration_date]).to eq(participant_declaration.declaration_date.rfc3339)
      expect(attrs[:course_identifier]).to eq("ecf-induction")
      expect(attrs[:state]).to eq("paid")
      expect(attrs[:updated_at]).to eq(participant_declaration.updated_at.rfc3339)
      expect(attrs[:has_passed]).to eq(nil)
    end
  end
end
