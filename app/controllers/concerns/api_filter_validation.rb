# frozen_string_literal: true

module ApiFilterValidation
  extend ActiveSupport::Concern

  included do
    before_action :validate_filters
  end

  module ClassMethods
    attr_reader :required_filters

  private

    def filter_validation(required_filters: [])
      @required_filters = required_filters.map(&:to_s)
    end
  end

private

  def filter
    params[:filter] ||= {}
  end

  def validate_filters
    return unless filter_errors.any?

    error_factory = Api::ParamErrorFactory.new(params: filter_errors, error: I18n.t(:bad_parameter))
    render json: { errors: error_factory.call }, status: :bad_request
  end

  def filter_errors
    (required_filter_errors << filter_format_error).compact
  end

  def filter_format_error
    "Filter must be a hash" unless filter.as_json.is_a?(Hash)
  end

  def required_filter_errors
    return [] if filter_format_error || self.class.required_filters.blank?

    (self.class.required_filters - filter.keys).map do |missing_filter|
      "The filter '#/#{missing_filter}' must be included in your request"
    end
  end
end
