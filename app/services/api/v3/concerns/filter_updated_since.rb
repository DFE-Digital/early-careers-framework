# frozen_string_literal: true

module Api::V3::Concerns::FilterUpdatedSince
  extend ActiveSupport::Concern

protected

  def filter
    params[:filter] ||= {}
  end

  def updated_since_filter
    filter[:updated_since]
  end

  def updated_since
    return if updated_since_filter.blank?

    Time.iso8601(filter[:updated_since])
  rescue ArgumentError
    begin
      Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
    rescue ArgumentError
      raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
    end
  end
end
