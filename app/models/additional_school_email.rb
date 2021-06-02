# frozen_string_literal: true

class AdditionalSchoolEmail < ApplicationRecord
  belongs_to :school
  validates :email_address, uniqueness: { scope: :school }
end
