# frozen_string_literal: true

class InductionChoiceForm
  include ActiveModel::Model

  attr_accessor :programme_choice

  validates :programme_choice, presence: { message: "Select one" } # TODO: custom validation message https://docs.google.com/document/d/1s8lAiYEbCYyXyqJGxGfCtWj2g_FBHqvxrI6WYWof18o/edit?disco=AAAAL3D9uU8

  def programme_choices
    [
      OpenStruct.new(id: "full_induction_programme", name: "a programme led by a training provider, funded by the Department for Education (DfE)"),
      OpenStruct.new(id: "core_induction_programme", name: "a programme led by the school, using accredited materials"),
    ]
  end
end
