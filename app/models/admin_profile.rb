# frozen_string_literal: true

class AdminProfile < ApplicationRecord
  belongs_to :user

  include Discard::Model
  default_scope -> { kept }
end
