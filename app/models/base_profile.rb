# frozen_string_literal: true

class BaseProfile < ApplicationRecord
  has_paper_trail

  self.abstract_class = true
  include Discard::Model

  default_scope -> { kept }

  after_undiscard do
    user.undiscard! unless user.kept?
  end
end
