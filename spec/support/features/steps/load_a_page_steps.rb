# frozen_string_literal: true

module Steps
  module LoadAPageSteps
    include RSpec::Matchers

    # Handles `when_i_{method_name}_from_{page_object}` to call a specific action of a specific page object
    # where `method_name` and `page_object`` are constantized
    # if it also end in `_with_{query_param}` then it is parsed and passed to #method_name

    def method_missing(method_symbol, *query_values)
      match_data = method_symbol.to_s.match given_i_am_on_matcher
      return super if match_data.nil?

      page_object_name, query_params = match_data[1].split("_with_")
      return super if page_object_name.nil?

      page_object = Pages.const_get(page_object_name.camelize).new
      query_params = query_params&.split("_") || []
      query_values = query_values.map(&:to_s)

      given_i_am_on page_object, query_params, query_values
    end

    def respond_to_missing?(method_symbol, include_private = false)
      method_symbol.to_s.match?(given_i_am_on_matcher) || super
    end

  private

    def given_i_am_on_matcher
      /^(?:given|when)_i_am_on_the_(.*)$/
    end

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
