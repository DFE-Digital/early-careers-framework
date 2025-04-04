# frozen_string_literal: true

class InductionChoiceForm
  include ActiveModel::Model
  include ActiveModel::Serialization
  include TrainingProgrammeOptions

  attr_reader :add_participant_after_complete, :programme_choice
  attr_accessor :school_cohort

  delegate :school, :cohort, to: :school_cohort

  def add_participant_after_complete=(value)
    @add_participant_after_complete = ActiveModel::Type::Boolean.new.cast(value).present?
  end

  def attributes
    {
      add_participant_after_complete: false,
      programme_choice: nil,
    }
  end

  validates :programme_choice, inclusion: { message: "Select how you want to run your training", in: ->(form) { form.programme_choices.map(&:id) } }

  def programme_choices
    school_training_options(state_funded: !school.cip_only?,
                            include_no_ects_option: true,
                            exclude: [school_cohort.induction_programme_choice].compact)
  end

  def opt_out_choice_selected?
    programme_choice&.in? %i[school_funded_fip design_our_own no_early_career_teachers]
  end

  def programme_choice=(value)
    @programme_choice = value&.to_sym
  end
end
