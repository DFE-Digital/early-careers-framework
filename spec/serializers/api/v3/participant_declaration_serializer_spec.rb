# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ParticipantDeclarationSerializer do
  subject { described_class.new(participant_declaration) }

  describe "#serializable_hash" do
    describe "ECF" do
      let(:participant_declaration) { create(:ect_participant_declaration, :paid, uplifts: [:sparsity_uplift], declaration_type: "started") }

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
        expect(attrs[:evidence_held]).to eq(nil)
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
    end

    describe "NPQ" do
      let(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }
      let(:participant_declaration) do
        create(
          :npq_participant_declaration,
          profile_traits: [:targeted_delivery_funding_eligibility],
          declaration_type: "started",
          npq_course:,
          state: "paid",
        )
      end

      it "returns correct hash" do
        data = subject.serializable_hash[:data]
        expect(data[:id]).to eq(participant_declaration.id)
        expect(data[:type]).to eq(:"participant-declaration")

        attrs = data[:attributes]
        expect(attrs[:participant_id]).to eq(participant_declaration.user.id)

        expect(attrs[:declaration_type]).to eq("started")
        expect(attrs[:declaration_date]).to eq(participant_declaration.declaration_date.rfc3339)
        expect(attrs[:mentor_id]).to be_nil
        expect(attrs[:course_identifier]).to eq("npq-leading-teaching")
        expect(attrs[:state]).to eq("paid")
        expect(attrs[:updated_at]).to eq(participant_declaration.updated_at.rfc3339)
        expect(attrs[:created_at]).to eq(participant_declaration.created_at.rfc3339)
        expect(attrs[:delivery_partner_id]).to eq(nil)
        expect(attrs[:statement_id]).to eq(participant_declaration.statement_line_items.billable.first&.statement_id)
        expect(attrs[:clawback_statement_id]).to eq(nil)
        expect(attrs[:ineligible_for_funding_reason]).to eq(nil)
        expect(attrs[:mentor_id]).to eq(nil)
        expect(attrs[:uplift_paid]).to eq(true)
        expect(attrs[:evidence_held]).to eq(nil)
        expect(attrs[:has_passed]).to eq(nil)
        expect(attrs[:lead_provider_name]).to eq(participant_declaration.cpd_lead_provider.name)
      end
    end
  end

  describe "#ineligible_for_funding_reason" do
    before do
      participant_declaration.make_ineligible!(reason: "duplicate")
    end

    describe "ECF" do
      let(:participant_declaration) { create(:ect_participant_declaration, :submitted) }

      it "returns state reason" do
        attrs = subject.serializable_hash[:data][:attributes]
        expect(attrs[:ineligible_for_funding_reason]).to eq("duplicate_declaration")
      end
    end

    describe "NPQ" do
      let(:participant_declaration) { create(:npq_participant_declaration, :submitted) }

      it "returns state reason" do
        attrs = subject.serializable_hash[:data][:attributes]
        expect(attrs[:ineligible_for_funding_reason]).to eq("duplicate_declaration")
      end
    end
  end

  describe "#evidence_held" do
    describe "ECF" do
      let(:participant_declaration) { create(:ect_participant_declaration, evidence_held: "training-event-attended") }

      it "returns evidence_held" do
        attrs = subject.serializable_hash[:data][:attributes]
        expect(attrs[:evidence_held]).to eq("training-event-attended")
      end
    end
  end

  describe "#has_passed" do
    let(:cpd_lead_provider) { create :cpd_lead_provider, :with_npq_lead_provider }
    let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
    let(:declaration_type) { "completed" }
    let(:declaration_date) { npq_application.profile.schedule.milestones.find_by(declaration_type:).start_date + 1.day }
    let(:participant_declaration) do
      travel_to declaration_date do
        create(:npq_participant_declaration, :eligible, declaration_type:, declaration_date:, participant_profile: npq_application.profile, has_passed:, cpd_lead_provider:)
      end
    end

    describe "when participant declaration does not have outcome" do
      let(:participant_declaration) do
        create(:npq_participant_declaration, :eligible, participant_profile: npq_application.profile, declaration_type: "started", cpd_lead_provider:)
      end

      it "returns nil" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(nil)
      end
    end

    describe "when participant outcome is true" do
      let(:has_passed) { true }

      it "returns true" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(true)
      end
    end

    describe "when participant outcome is false" do
      let(:has_passed) { false }

      it "returns false" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(false)
      end
    end
  end
end
