# frozen_string_literal: true

module Steps
  module VerifyAPageSteps
    include RSpec::Matchers

    def method_missing(method_name)
      name = method_name.to_s
      return super unless name.starts_with?("then_i_am_on_the_") || name.to_s.starts_with?("and_i_am_on_the_")

      page_object_name = name.gsub("then_i_am_on_the_", "").gsub("and_i_am_on_the_", "")
      page_object = Pages.const_get(page_object_name.camelize).new

      then_i_am_on page_object
    end

    def respond_to_missing?(method_name, include_private = false)
      name = method_name.to_s
      name.starts_with?("then_i_am_on_the_") || name.to_s.starts_with?("and_i_am_on_the_") || super
    end

  private

    def then_i_am_on(page_object)
      expect(page_object).to be_displayed
      expect(page_object).to have_primary_header
    end
  end
end
