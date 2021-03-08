# frozen_string_literal: true

class InductionCoordinatorProfile < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :schools

  include Discard::Model
  default_scope -> { kept }

  scope :kept, -> { undiscarded.joins(:user).merge(User.kept) }

  def kept?
    undiscarded? && user.kept?
  end
end
