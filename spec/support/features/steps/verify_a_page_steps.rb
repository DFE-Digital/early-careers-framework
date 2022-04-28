# frozen_string_literal: true

module Steps
  module VerifyAPageSteps
    include RSpec::Matchers

    # Handles `then_i_am_on_the_{page_object}` as well as `and_i_am_on_the_{page_object}`
    # where `page_object`` is constantized
    # if it also end in `_with_{query_param}` then it is parsed and passed to #displayed?

    def method_missing(method_name, *query_values)
      name = method_name.to_s
      return super unless name.starts_with?("then_i_am_on_the_") || name.to_s.starts_with?("and_i_am_on_the_")

      parts = name.gsub("then_i_am_on_the_", "").gsub("and_i_am_on_the_", "").split("_with_")
      page_object_name = parts.first
      query_params = parts.second&.split("_") || []
      page_object = Pages.const_get(page_object_name.camelize).new

      then_i_am_on page_object, query_params, query_values.map(&:to_s)
    end

    def respond_to_missing?(method_name, include_private = false)
      name = method_name.to_s
      name.starts_with?("then_i_am_on_the_") || name.to_s.starts_with?("and_i_am_on_the_") || super
    end

  private

    def then_i_am_on(page_object, query_params = [], query_values = [])
      args = {}
      unless query_params.empty?
        query_params.each_with_index do |key, i|
          args[key.to_sym] = query_values[i]
        end
      end

      expect(page_object).to be_displayed(args)
      expect(page_object).to have_primary_heading
    end
  end
end
