# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominateHowToContinueForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:how_to_continue).with_message("Tell us whether you expect to have any early career teachers this year") }
  end

  describe "#choices" do
    let(:cohort) { create(:cohort, :current) }
    subject(:form) { described_class.new(cohort: cohort) }

    it "provides options for the nomination induction tutor choices" do
      options = %w[yes no i_dont_know]
      expect(form.choices.map(&:id)).to match_array options
    end
  end

  describe "#opt_out?" do
    context "when 'yes' is selected" do
      subject(:form) { described_class.new(how_to_continue: "yes") }

      it "returns false" do
        expect(form.opt_out?).to eq false
      end
    end

    context "when 'no' is selected" do
      subject(:form) { described_class.new(how_to_continue: "no") }

      it "returns true" do
        expect(form.opt_out?).to eq true
      end
    end

    context "when 'i_dont_know' is selected" do
      subject(:form) { described_class.new(how_to_continue: "i_dont_know") }

      it "returns false" do
        expect(form.opt_out?).to eq false
      end
    end
  end
end
