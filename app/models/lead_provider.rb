class LeadProvider < ApplicationRecord
  has_many :partnerships
  has_many :schools, through: :partnerships
end
