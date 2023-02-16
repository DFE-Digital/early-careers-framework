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

        # Tests that returned outcomes are limited in scope to those associated with this participant declaration
        describe "#to_send_to_qualified_teachers_api" do
          subject(:outcomes) { declaration.outcomes.to_send_to_qualified_teachers_api }

          context "with a passed outcome" do
            context "not sent to the qualified teachers API" do
              let!(:passed_outcome) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
              let!(:other_outcome) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api) }

              it { is_expected.to eq(passed_outcome) }

              context "with a subsequently failed outcome" do
                let!(:failed_outcome) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
                let!(:other_failed_outcome) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api) }

                it { is_expected.to be_nil }
              end
            end

            context "sent to the qualified teachers API" do
              let!(:passed_outcome) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }
              let!(:other_outcome) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api) }

              it { is_expected.to be_nil }

              context "with a subsequently failed outcome" do
                let!(:failed_outcome) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
                let!(:other_failed_outcome) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api) }

                it { is_expected.to eq(failed_outcome) }
              end
            end
          end
        end
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

    describe "#with_outcomes_not_sent_to_qualified_teachers_api" do
      let!(:declaration_1) { create(:npq_participant_declaration) }
      let!(:declaration_2) { create(:npq_participant_declaration) }
      let!(:declaration_3) { create(:npq_participant_declaration) }

      before do
        create(:participant_outcome, :not_sent_to_qualified_teachers_api, participant_declaration: declaration_1)
        create(:participant_outcome, :sent_to_qualified_teachers_api, participant_declaration: declaration_2)
      end

      subject(:result) { described_class.with_outcomes_not_sent_to_qualified_teachers_api }

      it { is_expected.to include(declaration_1) }
      it { is_expected.not_to include(declaration_2) }
      it { is_expected.not_to include(declaration_3) }
    end
  end
end
