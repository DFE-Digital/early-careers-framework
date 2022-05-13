# frozen_string_literal: true

module Steps
  module InteractWithAPageSteps
    include RSpec::Matchers

    # Handles `(given|when|then|and)_i_{method_name}_from_{page_object}` to call a specific action of a specific page object
    # where `method_name` and `page_object`` are constantized
    # if it also end in `_with_{query_param}` then it is parsed and passed to #method_name

    def method_missing(method_symbol, *query_values)
      match_data = method_symbol.to_s.match given_i_call_matcher
      return super if match_data.nil?

      method_name = match_data[1]&.to_sym
      page_object_name, query_params = match_data[2].split("_with_")
      return super if page_object_name.nil? || method_name.nil?

      page_object = Pages.const_get(page_object_name.camelize)
      query_params = query_params&.split("_") || []

      given_i_call(page_object, method_name, query_params, query_values)
    end

    def respond_to_missing?(method_symbol, include_private = false)
      method_symbol.to_s.match?(given_i_call_matcher) || super
    end

  private

    def given_i_call_matcher
      /^(?:given|when|then|and)_i_(.*)_from_(.*)$/
    end

    def given_i_call(page_object, method_symbol, query_params = [], query_values = [])
      if query_params.blank? && query_values.blank?
        page_object.new.public_send(method_symbol)
      elsif query_params.blank? && query_values.any?
        page_object.new.public_send(method_symbol, *query_values)
      else
        args = {}
        query_params.each_with_index do |key, i|
          args[key.to_sym] = query_values[i]
        end

        page_object.new.public_send(method_symbol, args)
      end
    end
  end
end
