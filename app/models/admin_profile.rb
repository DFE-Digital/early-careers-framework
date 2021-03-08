# frozen_string_literal: true

class AdminProfile < ApplicationRecord
  belongs_to :user

  include Discard::Model
  default_scope -> { kept }

  scope :kept, -> { undiscarded.joins(:user).merge(User.kept) }

  def kept?
    undiscarded? && user.kept?
  end
end
