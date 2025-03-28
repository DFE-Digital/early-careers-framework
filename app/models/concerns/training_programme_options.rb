# frozen_string_literal: true

module TrainingProgrammeOptions
  extend ActiveSupport::Concern

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
    design_our_own: "Design and deliver your own programme based on the Early Career Framework (ECF)",
    no_early_career_teachers: "We do not expect any early career teachers to join",
  }.freeze

  # NOTE: These are to support 2025 programme type changes
  CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 = %i[
    school_funded_fip
    core_induction_programme
  ].freeze

  NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 = %i[
    full_induction_programme
    core_induction_programme
  ].freeze

  PROGRAMME_CHOICES_2025 = {
    full_induction_programme: {
      name: "Provider-led",
      description: "Your school will work with providers who will deliver early career framework based training funded by the Department for Education.",
    },
    core_induction_programme: {
      name: "School-led",
      description: "Your school will deliver training based on the early career framework.",
    },
    school_funded_fip: {
      name: "Provider-led",
      description: "Your school will fund providers who will deliver early career framework based training.",
    },
    no_early_career_teachers: {
      name: "We do not expect any early career teachers to join",
      description: "Your school does not expect any early career teachers this year and we will opt you out of notifications.",
    },
  }.freeze

  def school_training_options(state_funded: true, include_no_ects_option: false)
    if FeatureFlag.active?(:programme_type_changes_2025)
      school_choices_2025(state_funded, include_no_ects_option)
    else
      school_choices_pre_2025(state_funded, include_no_ects_option)
    end
  end

  def school_choices_pre_2025(state_funded, include_no_ects_option)
    choices = Array.new(state_funded ? NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES : CIP_ONLY_SCHOOL_PROGRAMME_CHOICES)
    choices << :no_early_career_teachers if include_no_ects_option
    choices.map { |id| OpenStruct.new(id:, name: PROGRAMME_CHOICES[id]) }
  end

  def school_choices_2025(state_funded, include_no_ects_option)
    choices = Array.new(state_funded ? NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 : CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025)
    choices << :no_early_career_teachers if include_no_ects_option
    choices.map do |id|
      OpenStruct.new(id:, name: PROGRAMME_CHOICES_2025[id][:name], description: PROGRAMME_CHOICES_2025[id][:description])
    end
  end
end
