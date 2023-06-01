# frozen_string_literal: true

class NominateHowToContinueForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :how_to_continue, :token, :school, :cohort

  delegate :academic_year_start_date, to: :cohort

  def attributes
    { how_to_continue: nil }
  end

  validates :how_to_continue, presence: { message: I18n.t("errors.how_to_continue.blank") }

  def choices
    [
      OpenStruct.new(id: "yes", name: "Yes"),
      OpenStruct.new(id: "no", name: "No"),
      OpenStruct.new(id: "we_dont_know", name: "We do not know yet"),
    ]
  end

  def opt_out?
    how_to_continue == "no"
  end
end
