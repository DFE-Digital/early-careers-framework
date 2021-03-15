# frozen_string_literal: true

class InductionCoordinatorProfile < BaseProfile
  belongs_to :user
  has_and_belongs_to_many :schools
end
