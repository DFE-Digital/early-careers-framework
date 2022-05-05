# frozen_string_literal: true

module Schools
  class SetupSchoolCohortForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serialization

    attr_accessor :expect_any_ects_choice, :how_will_you_run_training_choice, :change_provider_choice, :what_changes_choice

    validates :expect_any_ects_choice, presence: true, on: :expect_any_ects
    validates :how_will_you_run_training_choice, presence: true, on: :how_will_you_run_training
    validates :change_provider_choice, presence: true, on: :change_provider
    validates :what_changes_choice, presence: true, on: :what_changes

    PROGRAMME_CHOICES_MAP = {
      "change_lead_provider" => "full_induction_programme",
      "change_delivery_partner" => "full_induction_programme",
      "change_to_core_induction_programme" => "core_induction_programme",
      "change_to_design_our_own" => "design_our_own"
    }

    def attributes
      {
        expect_any_ects_choice: expect_any_ects_choice,
        how_will_you_run_training_choice: how_will_you_run_training_choice,
        change_provider_choice: change_provider_choice,
        what_changes_choice: what_changes_choice,
      }
    end

    def expect_any_ects_choices
      yes_no_choices
    end

    def how_will_you_run_training_choices
      [
        OpenStruct.new(id: "full_induction_programme", name: "Use a training provider, funded by the DfE"),
        OpenStruct.new(id: "core_induction_programme", name: "Deliver your own programme using DfE-accredited materials"),
        OpenStruct.new(id: "design_our_own", name: "Design and deliver you own programme based on the early career framework (ECF)"),
      ]
    end

    def what_changes_choices(lead_provider_name, delivery_partner_name)
      [
        OpenStruct.new(id: "change_lead_provider", name: "Leave #{lead_provider_name} and use a different lead provider"),
        OpenStruct.new(id: "change_delivery_partner", name: "Stay with #{lead_provider_name} but change your delivery partner, #{delivery_partner_name}"),
        OpenStruct.new(id: "change_to_core_induction_programme", name: "Deliver your own programme using DfE-accredited materials"),
        OpenStruct.new(id: "change_to_design_our_own", name: "Design and deliver you own programme based on the Early Career Framework (ECF)"),
      ]
    end

    def change_provider_choices
      yes_no_choices
    end

    def programme_choice
      PROGRAMME_CHOICES_MAP[what_changes_choice]
    end

  private

    def yes_no_choices
      [
        OpenStruct.new(id: "yes", name: "Yes"),
        OpenStruct.new(id: "no", name: "No"),
      ]
    end
  end
end
