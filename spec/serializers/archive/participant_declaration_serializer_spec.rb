# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::ParticipantDeclarationSerializer do
  let(:declaration) { create(:seed_ecf_participant_declaration, :valid) }

  subject { described_class.new(declaration) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq declaration.id
      expect(data[:type]).to eq :participant_declaration

      attrs = data[:attributes]
      expect(attrs[:type]).to eq declaration.type
      expect(attrs[:participant_profile_id]).to eq declaration.participant_profile_id
      expect(attrs[:cpd_lead_provider_id]).to eq declaration.cpd_lead_provider_id
      expect(attrs[:declaration_type]).to eq declaration.declaration_type
      expect(attrs[:declaration_date]).to eq declaration.declaration_date
      expect(attrs[:course_identifier]).to eq declaration.course_identifier
      expect(attrs[:user_id]).to eq declaration.user_id
      expect(attrs[:evidence_held]).to eq declaration.evidence_held
      expect(attrs[:state]).to eq declaration.state
      expect(attrs[:sparsity_uplift]).to eq declaration.sparsity_uplift
      expect(attrs[:pupil_premium_uplift]).to eq declaration.pupil_premium_uplift
      expect(attrs[:superseded_by_id]).to eq declaration.superseded_by_id
      expect(attrs[:delivery_partner_id]).to eq declaration.delivery_partner_id
      expect(attrs[:mentor_user_id]).to eq declaration.mentor_user_id
      expect(attrs[:created_at]).to eq declaration.created_at
    end
  end
end
