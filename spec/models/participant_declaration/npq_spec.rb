# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::NPQ, :with_default_schedules, type: :model do
  context "when declarations for a particular course are made" do
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
  end

  describe "scopes" do
    describe "#valid_to_have_outcome_for_lead_provider_and_course" do
      let!(:participant_declaration) { create(:npq_participant_declaration, :eligible) }

      before { participant_declaration.update!(declaration_type: "completed") }

      it "returns only valid declarations" do
        expect(described_class.valid_to_have_outcome_for_lead_provider_and_course(participant_declaration.cpd_lead_provider, participant_declaration.course_identifier)).to match([participant_declaration])
      end
    end

    describe "#for_course" do
      it "retrieves NPQ participant declarations by their course identifier" do
        identifier = "xyz"

        expect(described_class.for_course(identifier).to_sql).to include(%("participant_declarations"."course_identifier" = '#{identifier}'))
      end
    end
  end

  describe "instance methods" do
    describe "#qualification_type" do
      let(:identifier) { "npq-senior-leadership" }
      let(:npq_course) { create(:npq_course, identifier:) }
      let(:participant_declaration) { create(:npq_participant_declaration, npq_course:) }

      it "returns the formatted qualification type" do
        expect(participant_declaration.qualification_type).to eq("NPQSL")
      end
    end
  end
end
