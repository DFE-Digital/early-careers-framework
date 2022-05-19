# frozen_string_literal: true

module Steps
  module LoadAPageSteps
    include RSpec::Matchers

    def given_i_am_at_the_root_of_the_service
      visit "/"
    end

    def given_i_am_on_the_swagger_api_docs
      visit "/api-docs"
      expect(page.find("h2")).to have_content "Manage teacher CPD - lead provider API"
    end

    def given_i_am_on_the_user_research_page_for_ects
      visit "/pages/user-research"
      expect(page.find("h1")).to have_content "All research sessions are currently booked"
    end

    def given_i_am_on_the_user_research_page_for_mentors
      visit "/pages/user-research?mentor=true"
      expect(page.find("h1")).to have_content "All research sessions are currently booked"
    end

    def method_missing(method_name)
      name = method_name.to_s
      return super unless name.starts_with?("given_i_am_on_the_")

      page_object_name = name.gsub("given_i_am_on_the_", "")
      page_object = Pages.const_get(page_object_name.camelize).new

      given_i_am_on page_object
    end

    def respond_to_missing?(method_name, include_private = false)
      name = method_name.to_s
      name.starts_with?("given_i_am_on_the_") || super
    end

  private

    def given_i_am_on(page_object)
      page_object.load
      expect(page_object).to have_primary_header
    end
  end
end
