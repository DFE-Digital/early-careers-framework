# frozen_string_literal: true

module PageAssertionsHelper
  include Capybara::DSL

  def then_there_should_be_a_success_banner
    expect(page).to have_selector ".govuk-notification-banner--success"
  end

  alias_method :and_there_should_be_a_success_banner, :then_there_should_be_a_success_banner
end
