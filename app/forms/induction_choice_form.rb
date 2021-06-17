# frozen_string_literal: true

class InductionChoiceForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :programme_choice

  def attributes
    { programme_choice: nil }
  end

  validates :programme_choice, presence: { message: "Select how you want to run your induction" }

  def programme_choices
    [
      OpenStruct.new(id: "full_induction_programme", name: "Use a training provider, funded by the DfE (full induction programme)"),
      OpenStruct.new(id: "core_induction_programme", name: "Deliver your own programme using DfE accredited materials (core induction programme)"),
      OpenStruct.new(id: "design_our_own", name: "Design and deliver your own programme based on the Early Career Framework (ECF)"),
      OpenStruct.new(id: "no_early_career_teachers", name: "We don’t expect to have any early career teachers starting in #{cohort.display_name}"),
    ]
  end

  def opt_out_choice_selected?
    programme_choice&.in? %w[design_our_own no_early_career_teachers]
  end

  def cohort
    @cohort ||= Cohort.current
  end
end
