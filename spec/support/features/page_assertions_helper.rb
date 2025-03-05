# frozen_string_literal: true

module PageAssertionsHelper
  include Capybara::DSL

  def then_there_should_be_a_success_banner(message: nil)
    expect(page).to have_selector ".govuk-notification-banner--success"
    expect(find(".govuk-notification-banner--success")).to have_text(message) if message
  end

  alias_method :and_there_should_be_a_success_banner, :then_there_should_be_a_success_banner

  def then_there_should_be_an_important_banner(message: nil)
    expect(page).to have_selector ".govuk-notification-banner h2", text: "Important"
    expect(find(".govuk-notification-banner")).to have_text(message) if message
  end

  alias_method :and_there_should_be_an_important_banner, :then_there_should_be_an_important_banner

  def then_i_see_an_error_message(message)
    expect(page).to have_selector(".govuk-error-summary")
    expect(page).to have_selector(".govuk-error-message", text: message)
  end

  alias_method :and_i_see_an_error_message, :then_i_see_an_error_message
end
