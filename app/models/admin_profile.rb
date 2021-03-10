# frozen_string_literal: true

class AdminProfile < BaseProfile
  belongs_to :user

  include Discard::Model
  default_scope -> { kept }
end
