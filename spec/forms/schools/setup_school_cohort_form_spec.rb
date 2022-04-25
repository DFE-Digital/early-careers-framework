# frozen_string_literal: true

RSpec.describe Schools::SetupSchoolCohortForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:expect_any_ects_choice).on(:expect_any_ects) }
    it { is_expected.to validate_presence_of(:how_will_you_run_training_choice).on(:how_will_you_run_training) }
  end

  describe "#attributes" do
    it "returns a Hash" do
      expect(described_class.new.attributes).to be_a Hash
    end

    it "returns the user form choices" do
      choices = { expect_any_ects_choice: "yes", how_will_you_run_training_choice: "core_induction_programme" }
      expect(described_class.new(choices).attributes).to eq(choices)
    end
  end

  describe "#expect_any_ects_choices" do
    it "returns an Array with the correct choices" do
      expect(described_class.new.expect_any_ects_choices).to match_array(
        [
          have_attributes(class: OpenStruct, id: "yes", name: "Yes"),
          have_attributes(class: OpenStruct, id: "no", name: "No"),
        ],
      )
    end
  end

  describe "#how_will_you_run_training_choices" do
    it "returns an Array with the correct choices" do
      expect(described_class.new.how_will_you_run_training_choices).to match_array(
        [
          have_attributes(class: OpenStruct, id: "full_induction_programme", name: "Use a training provider, funded by the DfE"),
          have_attributes(class: OpenStruct, id: "core_induction_programme", name: "Deliver your own programme using DfE-accredited materials"),
          have_attributes(class: OpenStruct, id: "design_our_own", name: "Design and deliver you own programme based on the early career framework (ECF)"),
        ],
      )
    end
  end
end
