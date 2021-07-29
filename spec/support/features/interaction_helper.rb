# frozen_string_literal: true

module InteractionHelper
  include Capybara::DSL

  alias_method :when_i_click_the_link_containing, :click_link
  alias_method :and_i_click_the_link_containing, :click_link

  def when_i_click_the_submit_button
    click_button class: "govuk-button", name: "commit"
  end

  alias_method :and_i_click_the_submit_button, :when_i_click_the_submit_button

  def then_i_should_be_on(path)
    expect(page).to have_current_path path
  end

  alias_method :and_i_should_be_on, :then_i_should_be_on

  def when_i_visit(path)
    visit path
  end

  alias_method :and_i_visit, :when_i_visit
end
