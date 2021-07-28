# frozen_string_literal: true

class TeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true

  has_many :participant_profiles
end
