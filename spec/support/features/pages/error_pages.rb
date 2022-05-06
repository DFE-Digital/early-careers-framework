# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class ForbiddenPage < ::Pages::BasePage
    set_url "/403"
    set_primary_heading "Page not found"
  end

  class InternalServerErrorPage < ::Pages::BasePage
    set_url "/500"
    set_primary_heading "Sorry, there’s a problem with the service"
  end

  class PageNotFoundPage < ::Pages::BasePage
    set_url "/404"
    set_primary_heading "Page not found"
  end
end
