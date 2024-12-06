# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ParticipantDeclarationSerializer do
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
      expect(attrs[:created_at]).to eq(participant_declaration.created_at.rfc3339)
      expect(attrs[:delivery_partner_id]).to eq(participant_declaration.delivery_partner_id)
      expect(attrs[:statement_id]).to eq(participant_declaration.statement_line_items.billable.first&.statement_id)
      expect(attrs[:clawback_statement_id]).to eq(nil)
      expect(attrs[:ineligible_for_funding_reason]).to eq(nil)
      expect(attrs[:mentor_id]).to eq(nil)
      expect(attrs[:uplift_paid]).to eq(true)
      expect(attrs[:evidence_held]).to eq("training-event-attended")
      expect(attrs[:has_passed]).to eq(nil)
      expect(attrs[:lead_provider_name]).to eq(participant_declaration.cpd_lead_provider.name)
    end

    context "when the declaration has a mentor_user_id" do
      let(:mentor_profile) { create(:mentor_participant_profile) }
      let(:mentor_user_id) { mentor_profile.participant_identity.user_id }

      before { participant_declaration.update!(mentor_user_id:) }

      it "populates the mentor_id" do
        data = subject.serializable_hash[:data]
        attrs = data[:attributes]
        expect(attrs[:mentor_id]).to eq(mentor_user_id)
      end
    end

    context "when the declation is ineligible for funding" do
      let(:participant_declaration) { create(:ect_participant_declaration, :submitted) }

      before do
        participant_declaration.make_ineligible!(reason: "duplicate")
      end

      it "returns state reason" do
        attrs = subject.serializable_hash[:data][:attributes]
        expect(attrs[:ineligible_for_funding_reason]).to eq("duplicate_declaration")
      end
    end
  end
end
