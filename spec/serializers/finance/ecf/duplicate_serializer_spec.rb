# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::ECF::DuplicateSerializer, :with_default_schedules do
  describe "serialization" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
    let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) }
    let!(:participant_validation_data) { create :ecf_participant_validation_data, participant_profile:, trn: "8421937", full_name: "Rolande Mueller" }
    let!(:participant_eligibility) { create(:ecf_participant_eligibility, :eligible, participant_profile:) }

    subject { described_class.new(participant_profile) }

    it "returns the participant profile id" do
      result = subject.serializable_hash

      expect(result[:data][:id]).to eq(participant_profile.id)
    end

    it "returns the correct type" do
      result = subject.serializable_hash

      expect(result[:data][:type]).to eq(:duplicate)
    end

    it "returns the expected data attributes for the participant profile" do
      result = subject.serializable_hash

      expect(result[:data][:attributes]).to include(
        schedule_name: participant_profile.schedule.name,
        trn: participant_profile.teacher_profile.trn,
        external_identifier: participant_profile.participant_identity.external_identifier,
        email: participant_profile.participant_identity.email,
        cohort: "2021",
      )
    end

    it "returns the expected data attributes for the participant profile induction records" do
      result = subject.serializable_hash

      expect(result[:data][:attributes][:induction_records][0]).to include(
        cohort: "2021",
        training_status: "active",
        induction_status: "active",
        start_date: "2021-09-01T00:00:00Z",
        end_date: nil,
        school_transfer: false,
      )
    end

    it "returns the expected data attributes for the participant profile declarations" do
      result = subject.serializable_hash

      expect(result[:data][:attributes][:participant_declarations][0]).to include(
        declaration_type: "started",
        declaration_date: "2021-09-01T00:00:00Z",
        course_identifier: "ecf-induction",
      )
    end

    it "returns the expected data attributes for the participant profile states" do
      result = subject.serializable_hash

      expect(result[:data][:attributes][:participant_profile_states][0]).to include(
        reason: nil,
        state: "active",
      )
    end

    it "returns the expected data attributes for the participant profile validation data" do
      result = subject.serializable_hash

      expect(result[:data][:attributes][:participant_validation_data]).to include(
        trn: "8421937",
        full_name: "Rolande Mueller",
      )
    end

    it "returns the expected data attributes for the participant profile eligibility" do
      result = subject.serializable_hash

      expect(result[:data][:attributes][:participant_eligibility]).to include(
        status: "eligible",
        reason: "none",
      )
    end
  end
end
