# frozen_string_literal: true

class Network < ApplicationRecord
  extend AutoStripAttributes

  has_many :schools

  auto_strip_attributes :secondary_contact_email, nullify: false
end
