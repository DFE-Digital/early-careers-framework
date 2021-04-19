# frozen_string_literal: true

class InductionChoiceForm
  include ActiveModel::Model

  attr_accessor :programme_choice

  validates :programme_choice, presence: { message: "Select how you want to run your induction" }

  def programme_choices
    [
      OpenStruct.new(id: "full_induction_programme", name: "use an approved training provider"),
      OpenStruct.new(id: "core_induction_programme", name: "use the DfE accredited materials"),
    ]
  end
end
