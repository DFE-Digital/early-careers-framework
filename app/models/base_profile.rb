# frozen_string_literal: true

class BaseProfile < ApplicationRecord
  self.abstract_class = true
  scope :kept, -> { undiscarded.joins(:user).merge(User.kept) }

  def kept?
    undiscarded? && user.kept?
  end
end
