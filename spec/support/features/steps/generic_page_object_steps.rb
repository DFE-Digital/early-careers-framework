# frozen_string_literal: true

module Steps
  module GenericPageObjectSteps
    include RSpec::Matchers

    def method_missing(method_symbol, *query_values)
      match_data = method_symbol.to_s.match(generic_step_matcher)
      return super if match_data.nil?

      gwt_term = match_data[1]&.to_sym
      method_name = match_data[2]&.to_sym
      page_object_name, query_params = match_data[3].split("_with_")
      return super if page_object_name.nil? || method_name.nil?

      page_object = Pages.const_get(page_object_name.camelize)
      query_params = query_params&.split("_and_") || []

      if method_name == :am && %i[given when].include?(gwt_term)
        method_name = :load
      elsif method_name == :am && %i[then and].include?(gwt_term)
        method_name = :loaded
      else
        page_object = page_object.new
      end

      generic_call page_object, method_name, query_params, query_values
    end

    def respond_to_missing?(method_symbol, include_private = false)
      method_symbol.to_s.match?(generic_step_matcher) || super
    end

  private

    def generic_step_matcher
      /^(given|when|then|and)_i_(.*)_(?:from|on|to)_the_(.*)$/
    end

    def generic_call(page_object, method_symbol, query_params = [], query_values = [])
      if query_params.blank? && query_values.blank?
        page_object.public_send(method_symbol)
      elsif query_params.blank? && query_values.any?
        page_object.public_send(method_symbol, *query_values)
      else
        args = {}
        query_params.each_with_index do |key, i|
          args[key.to_sym] = query_values[i]
        end

        page_object.public_send(method_symbol, args)
      end
    end
  end
end
