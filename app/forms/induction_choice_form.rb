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
      OpenStruct.new(id: "full_induction_programme", name: "Use an approved training provider"),
      OpenStruct.new(id: "core_induction_programme", name: "Use the DfE accredited materials"),
    ]
  end
end
