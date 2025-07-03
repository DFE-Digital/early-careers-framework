# frozen_string_literal: true

module TrainingProgrammeOptions
  extend ActiveSupport::Concern

  CIP_ONLY_SCHOOL_PROGRAMME_CHOICES = %i[
    core_induction_programme
    school_funded_fip
    design_our_own
    no_early_career_teachers
  ].freeze

  NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES = %i[
    full_induction_programme
    core_induction_programme
    design_our_own
    no_early_career_teachers
  ].freeze

  PROGRAMME_CHOICES = {
    full_induction_programme: "Use a training provider, funded by the DfE",
    core_induction_programme: "Deliver your own programme using DfE-accredited materials",
    school_funded_fip: "Use a training provider funded by your school",
    design_our_own: "Design and deliver your own programme based on the early career framework (ECF)",
    no_early_career_teachers: "We do not expect any early career teachers to join",
  }.freeze

  PROGRAMME_SHORT_DESCRIPTION = {
    full_induction_programme: "Use a training provider funded by the DfE",
    core_induction_programme: "DfE-accredited materials",
    design_our_own: "Design and deliver your own programme based on the early career framework (ECF)",
    school_funded_fip: "Use a training provider funded by your school",
    no_early_career_teachers: "No early career teachers for this cohort",
    not_yet_known: "Not yet decided",
  }.freeze

  PROGRAMME_SHORT_DESCRIPTION_IN_USE = {
    core_induction_programme: "Using DfE-accredited materials",
    design_our_own: "Designing their own training",
    full_induction_programme: "Working with a DfE-funded provider",
    no_early_career_teachers: "No ECTs this year",
    school_funded_fip: "School-funded full induction programme",
  }.freeze

  # NOTE: These are to support 2025 programme type changes
  CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 = %i[
    school_funded_fip
    core_induction_programme
    no_early_career_teachers
  ].freeze

  NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 = %i[
    full_induction_programme
    core_induction_programme
    no_early_career_teachers
  ].freeze

  PROGRAMME_CHOICES_2025 = {
    full_induction_programme: {
      name: "Provider-led",
      description: "Your school will work with providers who will deliver initial teacher training and early career framework based training funded by the Department for Education.",
    },
    core_induction_programme: {
      name: "School-led",
      description: "Your school will deliver training based on the initial teacher training and early career framework.",
    },
    school_funded_fip: {
      name: "Provider-led",
      description: "Your school will fund providers who will deliver initial teacher training and early career framework based training.",
    },
    no_early_career_teachers: {
      name: "We do not expect any early career teachers to join",
      description: "Your school does not expect any early career teachers this year and we will opt you out of notifications.",
    },
  }.freeze

  PROGRAMME_SHORT_DESCRIPTION_2025 = {
    full_induction_programme: "Provider-led training funded by the DfE",
    core_induction_programme: "School-led training",
    design_our_own: "School-led training",
    school_funded_fip: "Provider-led training funded by your school",
    no_early_career_teachers: "No early career teachers for this cohort",
    not_yet_known: "Not yet decided",
  }.freeze

  CONFIRMATION_DESCRIPTION = {
    core_induction_programme: "deliver your own programme using DfE-accredited materials",
    full_induction_programme: "use a training provider, funded by the DfE",
    design_our_own: "design and deliver your own programme based on the early career framework (ECF)",
    school_funded_fip: "use a training provider funded by your school",
    no_early_career_teachers: "opt out of notifications, because you do not expect any early career teachers to join this academic year",
  }.freeze

  CONFIRMATION_DESCRIPTION_2025 = {
    core_induction_programme: "design and deliver your own training programme",
    full_induction_programme: "use provider-led training, funded by the DfE",
    school_funded_fip: "use provider-led training, funded by your school",
    no_early_career_teachers: "opt out of notifications, because you do not expect any early career teachers to join this academic year",
  }.freeze

  def school_training_options(state_funded: true, exclude: [])
    choices = possible_programmes(state_funded:, exclude:)

    if FeatureFlag.active?(:programme_type_changes_2025)
      choices.map do |id|
        OpenStruct.new(id:, name: PROGRAMME_CHOICES_2025[id][:name], description: PROGRAMME_CHOICES_2025[id][:description])
      end
    else
      choices.map { |id| OpenStruct.new(id:, name: PROGRAMME_CHOICES[id]) }
    end
  end

  def possible_programmes(state_funded: true, exclude: [])
    choices = if FeatureFlag.active?(:programme_type_changes_2025)
                Array.new(state_funded ? NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 : CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025)
              else
                Array.new(state_funded ? NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES : CIP_ONLY_SCHOOL_PROGRAMME_CHOICES)
              end

    choices.reject { |choice| choice.in? exclude.map(&:to_sym) }
  end

  def confirmation_description(training_programme:)
    if FeatureFlag.active?(:programme_type_changes_2025)
      CONFIRMATION_DESCRIPTION_2025[training_programme.to_sym]
    else
      CONFIRMATION_DESCRIPTION[training_programme.to_sym]
    end
  end
end
