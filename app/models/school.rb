class School < ApplicationRecord
  validates :name, presence: { message: "Enter the name of the school" }
  validates :opened, presence: { message: "Enter the date the school was first opened" }

  SCHOOL_TYPES = %w[Primary Secondary].freeze
end
