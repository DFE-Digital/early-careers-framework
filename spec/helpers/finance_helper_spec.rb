# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinanceHelper, type: :helper do
  describe "#number_to_pounds" do
    context "when negative zero" do
      it "returns unsigned zero" do
        expect(helper.number_to_pounds(BigDecimal("-0"))).to eql("£0.00")
      end
    end
  end

  describe "#float_to_percentage" do
    it "returns the percentage" do
      expect(helper.float_to_percentage(BigDecimal("0.12"))).to eql("12%")
    end
  end

  describe "#change_induction_record_training_status_button" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let(:row) { double }

    context "when action is displayed" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort: participant_profile.school_cohort) }
      let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

      it "returns the change training status action button" do
        expect(row).to receive(:action).with(
          text: "Change",
          visually_hidden_text: "training status",
          href: new_finance_participant_profile_ecf_induction_records_path(participant_profile.id, induction_record.id),
        )

        helper.change_induction_record_training_status_button(induction_record, participant_profile, row)
      end
    end

    context "when action is not displayed" do
      let!(:induction_record) { create(:induction_record, participant_profile:) }

      it "returns the change training status action button" do
        expect(row).to receive(:action).with(text: :none)

        helper.change_induction_record_training_status_button(induction_record, participant_profile, row)
      end
    end
  end
end
