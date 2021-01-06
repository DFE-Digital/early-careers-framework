# frozen_string_literal: true

class LeadProvider < ApplicationRecord
  has_many :partnerships
  has_many :schools, through: :partnerships

  validates :name, presence: { message: "Enter a name" }
end
