# frozen_string_literal: true

module ViewHelper
  def title_with_error_prefix(title, error:)
    "#{'Error: ' if error}#{title}"
  end
end