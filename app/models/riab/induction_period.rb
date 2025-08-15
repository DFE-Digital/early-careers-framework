# frozen_string_literal: true

module RIAB
  class InductionPeriod < ApplicationRecord
    belongs_to :teacher

    scope :ongoing, -> { where(finished_on: nil) }

    def complete? = finished_on.present?

    def induction_completion? = with_outcome? && complete?

    def with_outcome? = outcome.present?
  end
end
