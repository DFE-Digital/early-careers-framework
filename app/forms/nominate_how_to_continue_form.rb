# frozen_string_literal: true

class NominateHowToContinueForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :how_to_continue, :token, :school, :cohort

  def attributes
    { how_to_continue: nil }
  end

  validates :how_to_continue, presence: { message: "Tell us whether you expect to have any early career teachers this year" }

  def choices
    [
      OpenStruct.new(id: "yes", name: "Yes, (nominate someone to set up your induction for #{cohort.academic_year})"),
      OpenStruct.new(id: "no", name: "No, (opt out of updates about this service until the next academic year)"),
      OpenStruct.new(id: "i_dont_know", name: "I don’t know, (nominate someone to receive updates)"),
    ]
  end

  def opt_out?
    how_to_continue == "no"
  end
end
