# frozen_string_literal: true

class MentorCallOffContract < ApplicationRecord
  UNUSED_VERSION_PREFIX = "unused_"

  belongs_to :lead_provider
  belongs_to :cohort

  scope :not_flagged_as_unused, -> { where.not("version LIKE ?", "#{UNUSED_VERSION_PREFIX}%") }
end
