# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Start user journey", type: :feature, js: true, rutabaga: false do
  scenario "Start page is accessible" do
    given_i_am_at_the_root_of_the_service
    then_the_page_is_accessible
  end

private

  def given_i_am_at_the_root_of_the_service
    visit "/"
  end
end
