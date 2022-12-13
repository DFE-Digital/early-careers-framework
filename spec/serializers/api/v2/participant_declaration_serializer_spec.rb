# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ParticipantDeclarationSerializer, :with_default_schedules do
  describe "#has_passed", with_feature_flags: { participant_outcomes_feature: "active" } do
    let(:declaration_type) { "completed" }
    let(:npq_course) { create(:npq_leadership_course) }
    let(:schedule) { NPQCourse.schedule_for(npq_course:) }
    let(:declaration_date) { schedule.milestones.find_by(declaration_type:).start_date + 1.day }
    let(:participant_declaration) do
      travel_to declaration_date do
        create(:npq_participant_declaration, :eligible, declaration_type:, declaration_date:, has_passed:)
      end
    end

    describe "when participant declaration does not have outcome" do
      let(:participant_declaration) do
        create(:npq_participant_declaration, :eligible, declaration_type: "started")
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
      let(:has_passed) { true }

      let(:participant_declaration) do
        travel_to declaration_date do
          dec = create(:npq_participant_declaration, :eligible, declaration_type:, declaration_date:, has_passed:)
          dec.outcomes.first.update!(state: "failed")
          dec
        end
      end

      it "returns false" do
        result = described_class.new(participant_declaration).serializable_hash
        expect(result[:data][:attributes][:has_passed]).to eql(false)
      end
    end
  end
end
