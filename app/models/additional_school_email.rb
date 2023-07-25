# frozen_string_literal: true

class AdditionalSchoolEmail < ApplicationRecord
  extend AutoStripAttributes

  belongs_to :school
  validates :email_address, uniqueness: { scope: :school }

  auto_strip_attributes :email_address, nullify: false
end
