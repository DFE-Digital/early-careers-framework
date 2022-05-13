# frozen_string_literal: true

module Steps
  module VerifyAPageSteps
    include RSpec::Matchers

    # Handles `then_i_am_on_the_{page_object}` as well as `and_i_am_on_the_{page_object}`
    # where `page_object`` is constantized
    # if it also end in `_with_{query_param}` then it is parsed and passed to #displayed?

    def method_missing(method_symbol, *query_values)
      match_data = method_symbol.to_s.match then_i_am_on_matcher
      return super if match_data.nil?

      page_object_name, query_params = match_data[1].split("_with_")
      return super if page_object_name.nil?

      page_object = Pages.const_get(page_object_name.camelize)
      query_params = query_params&.split("_") || []
      query_values = query_values.map(&:to_s)

      then_i_am_on page_object, query_params, query_values
    end

    def respond_to_missing?(method_symbol, include_private = false)
      method_symbol.to_s.match?(then_i_am_on_matcher) || super
    end

  private

    def then_i_am_on_matcher
      /^(?:then|and)_i_am_on_the_(.*)$/
    end

    def then_i_am_on(page_object, query_params = [], query_values = [])
      if query_params.blank? && query_values.blank?
        page_object.loaded
      elsif query_params.blank? && query_values.any?
        page_object.loaded(*query_values)
      else
        args = {}
        query_params.each_with_index do |key, i|
          args[key.to_sym] = query_values[i]
        end

        page_object.loaded args
      end
    end
  end
end
