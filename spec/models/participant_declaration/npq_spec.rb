# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::NPQ, :with_default_schedules, type: :model do
  context "when declarations for a particular course are made" do
    before do
      create_list(:npq_participant_declaration, 20)
    end

    describe "associations" do
      subject(:declaration) { create(:npq_participant_declaration) }

      describe "outcomes" do
        it {
          is_expected.to have_many(:outcomes)
            .class_name("ParticipantOutcome::NPQ")
            .with_foreign_key("participant_declaration_id")
        }
      end
    end

    it "returns all records when not scoped" do
      expect(described_class.all.count).to eq(20)
    end

    it "can retrieve by npq courses attached" do
      expect(NPQCourse.identifiers.uniq.map { |course_identifier| described_class.for_course(course_identifier).count }.inject(:+)).to eq(20)
    end
  end

  describe "scopes" do
    describe "#valid_to_have_outcome_for_lead_provider_and_course" do
      let!(:participant_declaration) { create(:npq_participant_declaration, :eligible) }

      before { participant_declaration.update!(declaration_type: "completed") }

      it "returns only valid declarations" do
        expect(described_class.valid_to_have_outcome_for_lead_provider_and_course(participant_declaration.cpd_lead_provider, participant_declaration.course_identifier)).to match([participant_declaration])
      end
    end
  end
end
