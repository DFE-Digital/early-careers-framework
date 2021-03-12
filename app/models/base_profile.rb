# frozen_string_literal: true

class BaseProfile < ApplicationRecord
  self.abstract_class = true
  include Discard::Model

  default_scope -> { kept }

  after_discard do
    user.discard! unless user.discarded?
  end

  after_undiscard do
    user.undiscard! unless user.kept?
  end
end
