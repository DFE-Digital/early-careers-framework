# frozen_string_literal: true

module PaginationHelper
  OUTER_WINDOW = 1

  def govuk_paginate(scope, pagy=nil)
    if pagy
      render partial: 'shared/paginator', locals: {pagy: pagy}
    else
      paginate(scope, window: window(scope), outer_window: OUTER_WINDOW)
    end

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

  def pagy_window(pagy)
    case pagy.page
    when 1
      4
    when 2
      3
    when pagy.pages
      4
    when pagy.pages - 1
      3
    else
      2
    end
  end

  def pagy_size(pagy)
    window = pagy_window(pagy)
    [OUTER_WINDOW, window, window, OUTER_WINDOW]
  end
end
