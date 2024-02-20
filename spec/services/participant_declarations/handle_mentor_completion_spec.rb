# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclarations::HandleMentorCompletion do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:declaration_type) { "completed" }
  let(:course_identifier) { "ecf-mentor" }

  let(:participant_profile) { create(:seed_mentor_participant_profile, :valid) }

  let(:participant_declaration) do
    create(:seed_ecf_participant_declaration, user: participant_profile.user, participant_profile:, cpd_lead_provider:, course_identifier:, declaration_type:)
  end

  subject(:service) { described_class.new(participant_declaration:) }

  describe "#call" do
    context "when the declaration type is completed" do
      context "when the participant profile is a mentor" do
        it "calls the Mentors::CheckTrainingCompletion service" do
          expect_any_instance_of(Mentors::CheckTrainingCompletion).to receive(:call)
          service.call
        end
      end

      context "when the participant profile is not a mentor" do
        let(:course_identifier) { "ecf-induction" }
        let(:participant_profile) { create(:seed_ect_participant_profile, :valid) }

        it "does not call the Mentors::CheckTrainingCompletion service" do
          expect_any_instance_of(Mentors::CheckTrainingCompletion).not_to receive(:call)
          service.call
        end
      end
    end

    context "when the declaration type is not completed" do
      let(:declaration_type) { "started" }

      context "when the participant profile is a mentor" do
        it "does not call the Mentors::CheckTrainingCompletion service" do
          expect_any_instance_of(Mentors::CheckTrainingCompletion).not_to receive(:call)
          service.call
        end
      end

      context "when the participant profile is not a mentor" do
        let(:course_identifier) { "ecf-induction" }
        let(:participant_profile) { create(:seed_ect_participant_profile, :valid) }

        it "does not call the Mentors::CheckTrainingCompletion service" do
          expect_any_instance_of(Mentors::CheckTrainingCompletion).not_to receive(:call)
          service.call
        end
      end
    end
  end
end
