# frozen_string_literal: true

RSpec.describe Schools::SetupSchoolCohortForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:expect_any_ects_choice).on(:expect_any_ects) }
    it { is_expected.to validate_presence_of(:how_will_you_run_training_choice).on(:how_will_you_run_training) }
    it { is_expected.to validate_presence_of(:change_provider_choice).on(:change_provider) }
    it { is_expected.to validate_presence_of(:what_changes_choice).on(:what_changes) }
  end

  describe ".PROGRAMME_CHOICES_MAP" do
    it "returns a hash with the user programme choices and their respective programme types" do
      expect(described_class::PROGRAMME_CHOICES_MAP).to(
        eq(
          {
            change_lead_provider: :full_induction_programme,
            change_delivery_partner: :full_induction_programme,
            change_to_core_induction_programme: :core_induction_programme,
            change_to_design_our_own: :design_our_own,
          },
        ),
      )
    end
  end

  describe "#attributes" do
    it "returns a Hash" do
      expect(described_class.new.attributes).to be_a Hash
    end

    it "returns the user form choices" do
      choices = {
        expect_any_ects_choice: "yes",
        how_will_you_run_training_choice: "core_induction_programme",
        change_provider_choice: "yes",
        what_changes_choice: "change_lead_provider",
        use_different_delivery_partner_choice: "yes",
      }

      expect(described_class.new(choices).attributes).to eq(choices)
    end
  end

  describe "#expect_any_ects_choices" do
    it "returns an Array with the correct choices" do
      expect(described_class.new.expect_any_ects_choices).to(
        match_array(
          [
            have_attributes(class: OpenStruct, id: "yes", name: "Yes"),
            have_attributes(class: OpenStruct, id: "no", name: "No"),
          ],
        ),
      )
    end
  end

  describe "#use_different_delivery_partner_choices" do
    it "returns an Array with the correct choices" do
      expect(described_class.new.use_different_delivery_partner_choices).to(
        match_array(
          [
            have_attributes(class: OpenStruct, id: "yes", name: "Yes"),
            have_attributes(class: OpenStruct, id: "no", name: "No"),
          ],
        ),
      )
    end
  end

  describe "#how_will_you_run_training_choices" do
    context "when the school is CIP-only" do
      it "returns an Array with the correct choices" do
        expect(described_class.new.how_will_you_run_training_choices(cip_only: true)).to(
          match_array(
            [
              have_attributes(class: OpenStruct,
                              id: "core_induction_programme",
                              name: "Deliver your own programme using DfE-accredited materials"),
              have_attributes(class: OpenStruct,
                              id: "school_funded_fip",
                              name: "Use a training provider funded by your school"),
              have_attributes(class: OpenStruct,
                              id: "design_our_own",
                              name: "Design and deliver you own programme based on the early career framework (ECF)"),
            ],
          ),
        )
      end
    end

    context "when the school is not CIP-only" do
      it "returns an Array with the correct choices" do
        expect(described_class.new.how_will_you_run_training_choices).to(
          match_array(
            [
              have_attributes(class: OpenStruct,
                              id: "full_induction_programme",
                              name: "Use a training provider, funded by the DfE"),
              have_attributes(class: OpenStruct,
                              id: "core_induction_programme",
                              name: "Deliver your own programme using DfE-accredited materials"),
              have_attributes(class: OpenStruct,
                              id: "design_our_own",
                              name: "Design and deliver you own programme based on the early career framework (ECF)"),
            ],
          ),
        )
      end
    end
  end

  describe "#what_changes_choices" do
    it "returns an Array with the correct choices" do
      lead_provider_name = "lead provider"
      delivery_partner_name = "delivery partner"

      expect(described_class.new.what_changes_choices(lead_provider_name, delivery_partner_name)).to(
        match_array(
          [
            OpenStruct.new(id: "change_lead_provider",
                           name: "Leave #{lead_provider_name} and use a different lead provider"),
            OpenStruct.new(id: "change_delivery_partner",
                           name: "Stay with #{lead_provider_name} but change your delivery partner, #{delivery_partner_name}"),
            OpenStruct.new(id: "change_to_core_induction_programme",
                           name: "Deliver your own programme using DfE-accredited materials"),
            OpenStruct.new(id: "change_to_design_our_own",
                           name: "Design and deliver you own programme based on the Early Career Framework (ECF)"),
          ],
        ),
      )
    end
  end

  describe "#programme_choice" do
    it "returns the programme type based on what user chooses to change" do
      choices = { expect_any_ects_choice: "yes",
                  how_will_you_run_training_choice: "core_induction_programme",
                  change_provider_choice: "yes",
                  what_changes_choice: "change_lead_provider" }

      expect(described_class.new(choices).programme_choice).to eq("full_induction_programme")
    end
  end
end
