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

    def given_i_use_the_report_incorrect_partnership_token(challenge_token)
      Pages::ReportIncorrectPartnershipPage.load_from_email challenge_token
    end
    alias_method :when_i_use_the_report_incorrect_partnership_token, :given_i_use_the_report_incorrect_partnership_token
    alias_method :and_i_use_the_report_incorrect_partnership_token, :given_i_use_the_report_incorrect_partnership_token

    # Handles `given_i_am_on_the_{page_object}` to load a specific page via the URL
    # where `page_object`` is constantized
    # if it also end in `_with_{query_param}` then it is parsed and passed to #load

    def method_missing(method_name, *query_values)
      name = method_name.to_s
      return super unless name.starts_with?("given_i_am_on_the_") || name.to_s.starts_with?("when_i_am_on_the_")

      parts = name.gsub("given_i_am_on_the_", "").gsub("when_i_am_on_the_", "").split("_with_")
      page_object_name = parts.first
      query_params = parts.second&.split("_") || []
      page_object = Pages.const_get(page_object_name.camelize).new

      given_i_am_on page_object, query_params, query_values.map(&:to_s)
    end

    def respond_to_missing?(method_name, include_private = false)
      name = method_name.to_s
      name.starts_with?("given_i_am_on_the_") || name.to_s.starts_with?("when_i_am_on_the_") || super
    end

  private

    def given_i_am_on(page_object, query_params = [], query_values = [])
      args = {}
      unless query_params.empty?
        query_params.each_with_index do |key, i|
          args[key.to_sym] = query_values[i]
        end
      end

      page_object.load args
      expect(page_object).to have_primary_heading
    end
  end
end
