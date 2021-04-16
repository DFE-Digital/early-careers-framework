# frozen_string_literal: true

class CoreInductionProgrammeChoiceForm
  include ActiveModel::Model

  attr_accessor :core_induction_programme_id

  validates :core_induction_programme_id, presence: { message: "Select one" }

  def programme_choices
    CoreInductionProgramme
      .pluck(:id, :name)
      .map { |attrs| OpenStruct.new(attrs) }
  end
end
