# frozen_string_literal: true

module PageAssertionsHelper
  include Capybara::DSL

  def then_there_should_be_a_success_banner
    expect(page).to have_selector ".govuk-notification-banner--success"
  end

  alias_method :and_there_should_be_a_success_banner, :then_there_should_be_a_success_banner

  def then_i_see_an_error_message(message)
    expect(page).to have_selector(".govuk-error-summary")
    expect(page).to have_selector(".govuk-error-message", text: message)
  end

  alias_method :and_i_see_an_error_message, :then_i_see_an_error_message
end
