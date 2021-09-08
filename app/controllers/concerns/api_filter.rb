# frozen_string_literal: true

module ApiFilter
private

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
