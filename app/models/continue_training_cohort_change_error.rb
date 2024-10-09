# frozen_string_literal: true

class ContinueTrainingCohortChangeError < ApplicationRecord
  belongs_to :participant_profile

  validates :participant_profile, presence: true
  validates :message, presence: true
end
