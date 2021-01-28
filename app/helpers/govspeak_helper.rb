# frozen_string_literal: true

module GovspeakHelper
  def content_to_html(page)
    Govspeak::Document.new(page, options: { allow_extra_quotes: true }).to_html
  end
end
