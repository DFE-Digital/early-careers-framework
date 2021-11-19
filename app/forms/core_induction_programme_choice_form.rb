# frozen_string_literal: true

class CoreInductionProgrammeChoiceForm
  include ActiveModel::Model

  attr_accessor :core_induction_programme_id

  validates :core_induction_programme_id, presence: { message: I18n.t("errors.core_induction_programme.blank") }

  def programme_choices
    CoreInductionProgramme
      .pluck(:id, :name)
      .map { |attrs| OpenStruct.new(attrs) }
  end

  def core_induction_programme
    CoreInductionProgramme.find(core_induction_programme_id)
  end
end
