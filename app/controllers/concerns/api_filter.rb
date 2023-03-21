# frozen_string_literal: true

module ApiFilter
  extend ActiveSupport::Concern

  included do
    before_action :validate_filter_param
  end

private

  def validate_filter_param
    errors = []
    errors << "Filter must be a hash" unless filter.as_json.is_a?(Hash)
    missing_filter_params.each { |param| errors << "#{param} filter must be supplied" }

    if errors.any?
      error_factory = Api::ParamErrorFactory.new(params: errors, error: I18n.t(:bad_parameter))
      render json: { errors: error_factory.call }, status: :bad_request
    end
  end

  def filter
    params[:filter] ||= {}
  end

  def missing_filter_params
    return required_filter_params.map(&:to_s) - filter.keys if defined?(required_filter_params)

    []
  end

  def updated_since
    return if filter[:updated_since].blank?

    Time.iso8601(filter[:updated_since])
  rescue ArgumentError
    Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
  end

  def with_cohorts
    return Cohort.find_by(start_year: filter[:cohort]) if filter[:cohort].present?

    Cohort.where("start_year > 2020")
  end
end
