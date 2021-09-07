# frozen_string_literal: true

module ApiFilter
  extend ActiveSupport::Concern

  included do
    before_action :validate_filter_param
  end

private

  def validate_filter_param
    unless filter.as_json.is_a?(Hash)
      error_factory = Api::ParamErrorFactory.new(params: ["Filter must be a hash"], error: "Bad parameter")
      render json: { errors: error_factory.call }, status: :bad_request
    end
  end

  def filter
    params[:filter] ||= {}
  end

  def updated_since
    return if filter[:updated_since].blank?

    Time.iso8601(filter[:updated_since])
  rescue ArgumentError
    Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
  end
end
