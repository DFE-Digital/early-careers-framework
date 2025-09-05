# frozen_string_literal: true

module RIAB
  class Teacher < ApplicationRecord
    self.primary_key = :id

    has_many :induction_periods, class_name: "RIAB::InductionPeriod"
    has_one :first_induction_period, -> { order(started_on: :asc) }, class_name: "RIAB::InductionPeriod"
    has_one :last_induction_period, -> { order(started_on: :desc) }, class_name: "RIAB::InductionPeriod"

    def induction_completion_date
      last_induction_period&.finished_on if last_induction_period&.induction_completion?
    end

    def induction_in_progress?
      trs_induction_status == "InProgress" && ongoing_induction?
    end

    def induction_start_date
      first_induction_period&.started_on
    end

  private

    def ongoing_induction?
      induction_periods.ongoing.exists?
    end
  end
end
