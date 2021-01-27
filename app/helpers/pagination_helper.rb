# frozen_string_literal: true

module PaginationHelper
  def govuk_paginate(scope)
    paginate(scope, window: window(scope), outer_window: 1)
  end

private

  def window(scope)
    case scope.current_page
    when 1
      4
    when 2
      3
    when scope.total_pages
      4
    when scope.total_pages - 1
      3
    else
      2
    end
  end
end
