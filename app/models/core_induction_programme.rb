# frozen_string_literal: true

class CoreInductionProgramme < ApplicationRecord
  has_many :course_years, dependent: :delete_all
end
