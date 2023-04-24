# frozen_string_literal: true

class SyncDqtInductionStartDateError < ApplicationRecord
  belongs_to :participant_profile

  validates :participant_profile, presence: true
  validates :error_message, presence: true
end
