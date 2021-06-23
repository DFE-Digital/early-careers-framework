# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionChoiceForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:programme_choice).with_message("Select how you want to run your induction") }
  end

  describe "#programme_choices" do
    subject(:form) { described_class.new }

    before do
      create(:cohort, :current)
    end

    it "provides options for the programme choices" do
      options = SchoolCohort.induction_programme_choices.except("not_yet_known").keys
      expect(form.programme_choices.map(&:id)).to match_array options.map(&:to_sym)
    end
  end

  describe "#opt_out_choice_selected?" do
    context "when full induction programme is selected" do
      subject(:form) { described_class.new(programme_choice: "full_induction_programme") }
      it "returns false" do
        expect(form.opt_out_choice_selected?).to eq false
      end
    end

    context "when core induction programme is selected" do
      subject(:form) { described_class.new(programme_choice: "core_induction_programme") }
      it "returns false" do
        expect(form.opt_out_choice_selected?).to eq false
      end
    end

    context "when design our own programme is selected" do
      subject(:form) { described_class.new(programme_choice: "design_our_own") }
      it "returns true" do
        expect(form.opt_out_choice_selected?).to eq true
      end
    end

    context "when no early career teachers is selected" do
      subject(:form) { described_class.new(programme_choice: "no_early_career_teachers") }
      it "returns true" do
        expect(form.opt_out_choice_selected?).to eq true
      end
    end
  end

  describe "#cohort" do
    subject(:form) { described_class.new }

    before do
      create(:cohort, :current)
    end

    it "returns the current cohort" do
      expect(form.cohort).to eq Cohort.current
    end
  end
end
