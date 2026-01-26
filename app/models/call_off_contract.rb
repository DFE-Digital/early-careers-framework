# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  UNUSED_VERSION_PREFIX = "unused_"
  DEFAULT_REVISED_RECRUITMENT_TARGET_PERCENTAGE = 1.5

  belongs_to :lead_provider
  belongs_to :cohort

  has_many :participant_bands

  scope :not_flagged_as_unused, -> { where.not("version LIKE ?", "#{UNUSED_VERSION_PREFIX}%") }

  def bands
    participant_bands.min_nulls_first
  end

  def include_uplift_fees?
    !uplift_amount.nil?
  end
end
