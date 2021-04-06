# frozen_string_literal: true

class SchoolProfileForm
  include ActiveModel::Model

  attr_accessor :urn

  validates :urn, presence: { message: "Enter a school URN" }
  validate :urn_matches_school

private

  def urn_matches_school
    school = School.eligible.find_by(urn: urn)
    errors.add(:urn, :invalid, message: "No school matched that URN") if school.nil?
  end
end
