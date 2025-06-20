# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionChoiceForm, type: :model do
  let(:school) { build :school, school_type_code: 1 }
  let(:school_cohort) { build :school_cohort, school: }
  subject(:form) { described_class.new(school_cohort:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:programme_choice).with_message("Select how you want to run your training") }
  end

  describe "#programme_choices" do
    context "when programme_type_changes_2025 feature is inactive", with_feature_flags: { programme_type_changes_2025: "inactive" } do
      context "when the school has not yet made the choice" do
        let(:school_cohort) { build :school_cohort, school:, induction_programme_choice: nil }

        context "the school is eligible for the full induction programme" do
          it "provides options for the all programme choices except school_funded_fip" do
            options = SchoolCohort.induction_programme_choices.except("not_yet_known", "school_funded_fip").keys
            expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
          end
        end

        context "the school is cip only" do
          let(:school) { build(:school, :cip_only) }

          it "doesn't show the full induction programme as an option" do
            options = SchoolCohort.induction_programme_choices.except("not_yet_known", "full_induction_programme").keys
            expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
          end
        end
      end

      context "when the school has already made the choice for given cohort" do
        let(:previous_choice) { SchoolCohort.induction_programme_choices.except("not_yet_known", "school_funded_fip").keys.sample }
        let(:school_cohort) { build :school_cohort, school:, induction_programme_choice: previous_choice }

        it "does not show previous selection as an option" do
          options = SchoolCohort.induction_programme_choices.except("not_yet_known", "school_funded_fip", previous_choice).keys
          expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
        end
      end
    end

    context "when programme_type_changes_2025 feature is active", with_feature_flags: { programme_type_changes_2025: "active" } do
      context "when the school has not yet made the choice" do
        let(:school_cohort) { build :school_cohort, school:, induction_programme_choice: nil }

        context "the school is eligible for the full induction programme" do
          it "provides options for the all programme choices except school_funded_fip and design_our_own" do
            options = SchoolCohort.induction_programme_choices.except("not_yet_known", "school_funded_fip", "design_our_own").keys
            expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
          end
        end

        context "the school is cip only" do
          let(:school) { build(:school, :cip_only) }

          it "doesn't show the full induction programme as an option" do
            options = SchoolCohort.induction_programme_choices.except("not_yet_known", "full_induction_programme", "design_our_own").keys
            expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
          end
        end
      end

      context "when the school has already made the choice for given cohort" do
        let(:previous_choice) { SchoolCohort.induction_programme_choices.except("not_yet_known", "school_funded_fip", "design_our_own").keys.sample }
        let(:school_cohort) { build :school_cohort, school:, induction_programme_choice: previous_choice }

        it "does not show previous selection as an option" do
          options = SchoolCohort.induction_programme_choices.except("not_yet_known", "school_funded_fip", "design_our_own", previous_choice).keys
          expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
        end
      end
    end
  end

  describe "#opt_out_choice_selected?" do
    before do
      form.programme_choice = programme_choice
    end

    context "when full induction programme is selected" do
      let(:programme_choice) { "full_induction_programme" }

      it "returns false" do
        expect(form.opt_out_choice_selected?).to eq false
      end
    end

    context "when core induction programme is selected" do
      let(:programme_choice) { "core_induction_programme" }

      it "returns false" do
        expect(form.opt_out_choice_selected?).to eq false
      end
    end

    context "when design our own programme is selected" do
      let(:programme_choice) { "design_our_own" }

      it "returns true" do
        expect(form.opt_out_choice_selected?).to eq true
      end
    end

    context "when no early career teachers is selected" do
      let(:programme_choice) { "no_early_career_teachers" }

      it "returns true" do
        expect(form.opt_out_choice_selected?).to eq true
      end
    end
  end

  describe "#programme_confirmation_description" do
    context "when programme_type_changes_2025 flag is inactive", with_feature_flags: { programme_type_changes_2025: "inactive" } do
      %w[full_induction_programme core_induction_programme design_our_own school_funded_fip no_early_career_teachers].each do |programme_choice|
        it "returns the correct description for the confirmation page" do
          form.programme_choice = programme_choice
          expect(form.programme_confirmation_description).to eq TrainingProgrammeOptions::CONFIRMATION_DESCRIPTION[programme_choice.to_sym]
        end
      end
    end

    context "when programme_type_changes_2025 flag is active", with_feature_flags: { programme_type_changes_2025: "active" } do
      %w[full_induction_programme core_induction_programme school_funded_fip no_early_career_teachers].each do |programme_choice|
        it "returns the correct description for the confirmation page" do
          form.programme_choice = programme_choice
          expect(form.programme_confirmation_description).to eq TrainingProgrammeOptions::CONFIRMATION_DESCRIPTION_2025[programme_choice.to_sym]
        end
      end
    end
  end
end
