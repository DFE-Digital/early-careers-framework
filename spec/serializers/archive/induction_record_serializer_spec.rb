# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::InductionRecordSerializer do
  let(:profile) { create(:seed_ect_participant_profile, :valid) }
  let!(:induction_record) { create(:seed_induction_record, :with_induction_programme, participant_profile: profile) }

  subject { described_class.new(induction_record) }

  describe "#serializable_hash" do
    it "generates the correct hash" do
      data = subject.serializable_hash[:data]
      expect(data[:id]).to eq induction_record.id
      expect(data[:type]).to eq :induction_record

      attrs = data[:attributes]
      expect(attrs[:lead_provider]).to eq induction_record.lead_provider_name
      expect(attrs[:delivery_partner]).to eq induction_record.delivery_partner_name
      expect(attrs[:core_materials]).to eq induction_record.core_induction_programme_name
      expect(attrs[:appropriate_body]).to eq induction_record.appropriate_body_name
      expect(attrs[:participant_profile_id]).to eq induction_record.participant_profile_id
      expect(attrs[:schedule_id]).to eq induction_record.schedule_id
      expect(attrs[:induction_programme_id]).to eq induction_record.induction_programme_id
      expect(attrs[:induction_status]).to eq induction_record.induction_status
      expect(attrs[:training_status]).to eq induction_record.training_status
      expect(attrs[:start_date]).to eq induction_record.start_date
      expect(attrs[:end_date]).to eq induction_record.end_date
      expect(attrs[:school_transfer]).to eq induction_record.school_transfer
      expect(attrs[:preferred_identity_id]).to eq induction_record.preferred_identity_id
      expect(attrs[:mentor_profile_id]).to eq induction_record.mentor_profile_id
      expect(attrs[:appropriate_body_id]).to eq induction_record.appropriate_body_id
      expect(attrs[:created_at]).to eq induction_record.created_at
    end
  end
end
