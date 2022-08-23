# frozen_string_literal: true

module Schools
  class SetupSchoolCohortForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serialization

    attr_accessor :expect_any_ects_choice, :how_will_you_run_training_choice, :change_provider_choice,
                  :what_changes_choice, :use_different_delivery_partner_choice

    validates :expect_any_ects_choice, presence: true, on: :expect_any_ects
    validates :how_will_you_run_training_choice, presence: true, on: :how_will_you_run_training
    validates :change_provider_choice, presence: true, on: :change_provider
    validates :what_changes_choice, presence: true, on: :what_changes
    validates :use_different_delivery_partner_choice, presence: true, on: :use_different_delivery_partner

    CIP_ONLY_SCHOOL_PROGRAMME_CHOICES = %i[
      core_induction_programme
      school_funded_fip
      design_our_own
    ].freeze

    NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES = %i[
      full_induction_programme
      core_induction_programme
      design_our_own
    ].freeze

    PROGRAMME_CHOICES = {
      full_induction_programme: "Use a training provider, funded by the DfE",
      core_induction_programme: "Deliver your own programme using DfE-accredited materials",
      school_funded_fip: "Use a training provider funded by your school",
      design_our_own: "Design and deliver you own programme based on the early career framework (ECF)",
    }.freeze

    PROGRAMME_CHOICES_MAP = {
      change_lead_provider: :full_induction_programme,
      change_delivery_partner: :full_induction_programme,
      change_to_core_induction_programme: :core_induction_programme,
      change_to_design_our_own: :design_our_own,
    }.freeze

    def attributes
      {
        expect_any_ects_choice:,
        how_will_you_run_training_choice:,
        change_provider_choice:,
        what_changes_choice:,
        use_different_delivery_partner_choice:,
      }
    end

    def change_provider_choices
      yes_no_choices
    end
    alias_method :expect_any_ects_choices, :change_provider_choices
    alias_method :use_different_delivery_partner_choices, :change_provider_choices

    def how_will_you_run_training_choices(cip_only: false)
      choices = cip_only ? CIP_ONLY_SCHOOL_PROGRAMME_CHOICES : NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES
      choices.map { |choice| programme_choice_option(choice) }
    end

    def programme_choice
      PROGRAMME_CHOICES_MAP[what_changes_choice.to_sym].to_s
    end

    def what_changes_choices(lead_provider_name, delivery_partner_name)
      [
        OpenStruct.new(id: "change_lead_provider", name: "Leave #{lead_provider_name} and use a different lead provider"),
        OpenStruct.new(id: "change_delivery_partner", name: "Stay with #{lead_provider_name} but change your delivery partner, #{delivery_partner_name}"),
        OpenStruct.new(id: "change_to_core_induction_programme", name: "Deliver your own programme using DfE-accredited materials"),
        OpenStruct.new(id: "change_to_design_our_own", name: "Design and deliver you own programme based on the Early Career Framework (ECF)"),
      ]
    end

  private

    def programme_choice_option(id)
      OpenStruct.new(id: id.to_s, name: PROGRAMME_CHOICES[id])
    end

    def yes_no_choices
      [
        OpenStruct.new(id: "yes", name: "Yes"),
        OpenStruct.new(id: "no", name: "No"),
      ]
    end
  end
end
