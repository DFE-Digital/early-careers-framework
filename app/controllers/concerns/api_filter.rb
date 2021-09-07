# frozen_string_literal: true

module ApiFilter
private

  def filter
    params[:filter] ||= {}
  end

  def updated_since
    return unless filter[:updated_since]

    Time.iso8601(filter[:updated_since]) if filter[:updated_since].present?
  rescue ArgumentError
    Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
  end
end
