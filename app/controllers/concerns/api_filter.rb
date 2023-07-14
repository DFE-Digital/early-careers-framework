# frozen_string_literal: true

module ApiFilter
  extend ActiveSupport::Concern

private

  def filter
    params[:filter] ||= {}
  end

  def updated_since
    return if filter[:updated_since].blank?

    Time.iso8601(filter[:updated_since])
  rescue ArgumentError
    begin
      Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
    rescue ArgumentError
      raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
    end
  end

  def with_cohorts
    return Cohort.find_by(start_year: filter[:cohort]) if filter[:cohort].present?

    Cohort.where("start_year > 2020")
  end
end
