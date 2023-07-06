# frozen_string_literal: true

module Api::V3::Concerns::FilterCohorts
  extend ActiveSupport::Concern

protected

  def filter
    params[:filter] ||= {}
  end

  def cohort_filter
    filter[:cohort].to_s
  end

  def cohorts
    return Cohort.where("start_year > 2020") if cohort_filter.blank?

    Cohort.where(start_year: cohort_filter.split(","))
  end

  def cohort
    Cohort.find_by(start_year: cohort_filter)
  end

  def cohort_years
    cohort_filter&.split(",")
  end
end
