# frozen_string_literal: true

require "rails_helper"

RSpec.describe EvidenceHeldValidator, mid_cohort: true do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      validates :evidence_held, evidence_held: true

      attr_accessor :participant_profile, :schedule, :cohort, :declaration_type, :evidence_held

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def initialize(participant_profile:, schedule:, cohort:, declaration_type:, evidence_held:)
        @participant_profile = participant_profile
        @schedule = schedule
        @cohort = cohort
        @declaration_type = declaration_type
        @evidence_held = evidence_held
      end
    end
  end

  describe "#validate" do
    let(:participant_profile) { declaration.participant_profile }
    let(:schedule) { participant_profile.schedule }
    let(:cohort) { declaration.cohort }
    let(:declaration_type) { declaration.declaration_type }
    let(:evidence_held) { "other" }

    subject { klass.new(participant_profile:, schedule:, cohort:, declaration_type:, evidence_held:) }

    context "ECT participant" do
      let(:declaration) { create(:ect_participant_declaration) }

      context "with valid params" do
        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when cohort has detailed evidence types" do
        before { cohort.update!(detailed_evidence_types: true) }

        context "when `declaration_type` is started" do
          let(:declaration) { create(:ect_participant_declaration, declaration_type: "started") }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "has a meaningful error", :aggregate_failures do
                expect(subject).to be_invalid
                expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
              end
            end
          end
        end

        context "when `declaration_type` is other than started or completed" do
          let(:declaration) { create(:ect_participant_declaration, declaration_type: "retained-1") }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "has a meaningful error", :aggregate_failures do
              expect(subject).to be_invalid
              expect(subject.errors.messages_for(:evidence_held)).to include("Enter a '#/evidence_held' value for this participant.")
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "has a meaningful error", :aggregate_failures do
                expect(subject).to be_invalid
                expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
              end
            end
          end
        end
      end

      context "when cohort has not detailed evidence types" do
        context "when `declaration_type` is started" do
          let(:declaration) { create(:ect_participant_declaration, declaration_type: "started") }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid (sets the `evidence_held` to `nil`)" do
              expect(subject).to be_valid
              expect(subject.evidence_held).to be_nil
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "is valid" do
                expect(subject).to be_valid
              end
            end
          end
        end

        context "when `declaration_type` is other than started" do
          let(:declaration) { create(:ect_participant_declaration, declaration_type: %w[retained-1 retained-2].sample) }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "has a meaningful error", :aggregate_failures do
              expect(subject).to be_invalid
              expect(subject.errors.messages_for(:evidence_held)).to include("Enter a '#/evidence_held' value for this participant.")
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "has a meaningful error", :aggregate_failures do
                expect(subject).to be_invalid
                expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
              end
            end
          end
        end
      end
    end

    context "Mentor participant" do
      let(:declaration) { create(:mentor_participant_declaration) }

      context "with valid params" do
        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when cohort has detailed evidence types" do
        before { cohort.update!(detailed_evidence_types: true) }

        context "when `declaration_type` is started" do
          let(:declaration) { create(:mentor_participant_declaration, declaration_type: "started") }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "has a meaningful error", :aggregate_failures do
                expect(subject).to be_invalid
                expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
              end
            end
          end
        end

        context "when `declaration_type` is completed" do
          let(:cohort) { Cohort.current || create(:cohort, :current) }
          let(:schedule) { Finance::Schedule.find_by(schedule_identifier: "ecf-standard-september", cohort:) }
          let(:declaration) do
            travel_to schedule.milestones.find_by(declaration_type: "completed").milestone_date do
              create(:mentor_participant_declaration, declaration_type: "completed", cohort:)
            end
          end

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "has a meaningful error", :aggregate_failures do
              expect(subject).to be_invalid
              expect(subject.errors.messages_for(:evidence_held)).to include("Enter a '#/evidence_held' value for this participant.")
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "75-percent-engagement-met" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "has a meaningful error", :aggregate_failures do
                expect(subject).to be_invalid
                expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
              end
            end
          end
        end

        context "when `declaration_type` is other than started or completed" do
          let(:declaration) { create(:mentor_participant_declaration, declaration_type: "retained-1") }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "has a meaningful error", :aggregate_failures do
              expect(subject).to be_invalid
              expect(subject.errors.messages_for(:evidence_held)).to include("Enter a '#/evidence_held' value for this participant.")
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "has a meaningful error", :aggregate_failures do
              expect(subject).to be_invalid
              expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
            end
          end
        end
      end

      context "when cohort has not detailed evidence types" do
        context "when `declaration_type` is started" do
          let(:declaration) { create(:mentor_participant_declaration, declaration_type: "started") }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "is valid" do
              expect(subject).to be_valid
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "is valid" do
                expect(subject).to be_valid
              end
            end
          end
        end

        context "when `declaration_type` is other than started" do
          let(:declaration) { create(:mentor_participant_declaration, declaration_type: %w[retained-1 retained-2].sample) }

          context "when `evidence_held` is not present" do
            let(:evidence_held) { nil }

            it "has a meaningful error", :aggregate_failures do
              expect(subject).to be_invalid
              expect(subject.errors.messages_for(:evidence_held)).to include("Enter a '#/evidence_held' value for this participant.")
            end
          end

          context "when `evidence_held` is present" do
            let(:evidence_held) { "other" }

            it "is valid" do
              expect(subject).to be_valid
            end

            context "when `evidence_held` is invalid" do
              let(:evidence_held) { "one-term-induction" }

              it "has a meaningful error", :aggregate_failures do
                expect(subject).to be_invalid
                expect(subject.errors.messages_for(:evidence_held)).to include("Enter an available '#/evidence_held' type for this participant's event and course.")
              end
            end
          end
        end
      end
    end
  end
end
