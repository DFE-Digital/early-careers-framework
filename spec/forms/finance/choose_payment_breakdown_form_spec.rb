# frozen_string_literal: true

RSpec.describe Finance::ChoosePaymentBreakdownForm, type: :model do
  let(:form) { described_class.new({}) }

  describe "programme_choices" do
    it "returns the programme choices for NPQ and ECF" do
      expect(form.programme_choices).to match_array([
        OpenStruct.new(id: "ecf", name: "ECF payments"),
        OpenStruct.new(id: "npq", name: "NPQ payments"),
      ])
    end

    context "when disable_npq feature is on" do
      it "returns the programme choices for ECF only" do
        FeatureFlag.activate(:disable_npq)

        expect(form.programme_choices).to match_array([
          OpenStruct.new(id: "ecf", name: "ECF payments"),
        ])
      end
    end
  end
end
