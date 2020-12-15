# frozen_string_literal: true

class SchoolDomain < ApplicationRecord
  has_and_belongs_to_many :schools
end
