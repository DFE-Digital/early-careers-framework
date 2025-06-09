# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::CohortSetupHelper, type: :helper do
  describe "#training_confirmation_template" do
    context "when programme type changes for 2025 are inactive", with_feature_flags: { programme_type_changes_2025: "inactive" } do
      it "returns the original confirmation mapping" do
        expect(helper.training_confirmation_template(:full_induction_programme)).to eq("training_confirmation_fip")
        expect(helper.training_confirmation_template(:core_induction_programme)).to eq("training_confirmation_cip")
        expect(helper.training_confirmation_template(:school_funded_fip)).to eq("training_confirmation_school_funded_fip")
        expect(helper.training_confirmation_template(:design_our_own)).to eq("training_confirmation_diy")
      end
    end

    context "when programme type changes for 2025 are active", with_feature_flags: { programme_type_changes_2025: "active" } do
      it "returns the 2025 confirmation mapping" do
        expect(helper.training_confirmation_template(:full_induction_programme)).to eq("training_confirmation_fip")
        expect(helper.training_confirmation_template(:core_induction_programme)).to eq("training_confirmation_cip")
        expect(helper.training_confirmation_template(:school_funded_fip)).to eq("training_confirmation_school_funded_fip_2025")
        expect(helper.training_confirmation_template(:design_our_own)).to eq("training_confirmation_cip")
      end
    end
  end

  describe "#programme_radio_options" do
    let(:school_cohort) { FactoryBot.create(:school_cohort) }
    let(:form_object) { InductionChoiceForm.new(school_cohort:) }
    let(:form_builder) { GOVUKDesignSystemFormBuilder::FormBuilder.new(:test, form_object, helper, {}) }
    let(:choices) { form_object.programme_choices }
    let(:legend) { "Programme choices" }
    let(:output) { helper.programme_radio_options(form_builder, :programme_choice, choices, legend) }

    context "when programme type changes for 2025 are inactive", with_feature_flags: { programme_type_changes_2025: "inactive" } do
      it "returns the options for the choices in the original format" do
        expect(output).to match(/<h1\s.*#{legend}<\/h1>/)
        choices.each do |choice|
          expect(output).to include(choice.id.to_s).once
          expect(output).to include(choice.name.to_s).once
          expect(choice).not_to respond_to :description
        end
      end
    end

    context "when programme type changes for 2025 are active", with_feature_flags: { programme_type_changes_2025: "active" } do
      it "returns the options for the choices in the 2025 format" do
        expect(output).to match(/<h1\s.*#{legend}<\/h1>/)
        choices.each do |choice|
          expect(output).to include(choice.id.to_s).once
          expect(output).to include(choice.name.to_s).once
          expect(output).to include(choice.description.to_s).once
        end
      end
    end
  end
end
