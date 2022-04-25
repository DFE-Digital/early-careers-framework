# frozen_string_literal: true

module Schools
  class SetupSchoolCohortForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serialization

    attr_accessor :expect_any_ects_choice, :how_will_you_run_training_choice

    validates :expect_any_ects_choice, presence: true, on: :expect_any_ects
    validates :how_will_you_run_training_choice, presence: true, on: :how_will_you_run_training

    def attributes
      {
        expect_any_ects_choice: expect_any_ects_choice,
        how_will_you_run_training_choice: how_will_you_run_training_choice,
      }
    end

    def expect_any_ects_choices
      [
        OpenStruct.new(id: "yes", name: "Yes"),
        OpenStruct.new(id: "no", name: "No"),
      ]
    end

    def how_will_you_run_training_choices
      [
        OpenStruct.new(id: "full_induction_programme", name: "Use a training provider, funded by the DfE"),
        OpenStruct.new(id: "core_induction_programme", name: "Deliver your own programme using DfE-accredited materials"),
        OpenStruct.new(id: "design_our_own", name: "Design and deliver you own programme based on the early career framework (ECF)"),
      ]
    end
  end
end
