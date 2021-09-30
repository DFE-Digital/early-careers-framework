# frozen_string_literal: true

class InductionChoiceForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_reader :programme_choice
  attr_writer :cohort
  attr_accessor :school

  PROGRAMME_OPTIONS = %i[full_induction_programme core_induction_programme design_our_own school_funded_fip no_early_career_teachers].freeze

  def attributes
    { programme_choice: nil }
  end

  validates :programme_choice, presence: { message: "Select how you want to run your induction" }, inclusion: { in: PROGRAMME_OPTIONS }

  def programme_choices(i18n_scope: "schools.induction_choice_form.options")
    options =
      if school.cip_only?
        PROGRAMME_OPTIONS.excluding(:full_induction_programme)
      else
        PROGRAMME_OPTIONS.excluding(:school_funded_fip)
      end

    options.map do |option|
      OpenStruct.new(
        id: option,
        name: I18n.t(
          option,
          scope: i18n_scope,
          cohort: cohort.display_name,
        ),
      )
    end
  end

  def opt_out_choice_selected?
    programme_choice&.in? %i[school_funded_fip design_our_own no_early_career_teachers]
  end

  def cohort
    @cohort ||= Cohort.current
  end

  def programme_choice=(value)
    @programme_choice = value&.to_sym
  end
end
