# frozen_string_literal: true

module OrderHelper
  def elements_in_order(elements:, get_previous_element:)
    all_elements_in_order = []

    current_elements = elements.filter { |element| elements.exclude?(element.send(get_previous_element)) }
    until current_elements.empty?
      all_elements_in_order += current_elements
      remaining_elements = elements.reject { |element| all_elements_in_order.include?(element) }
      current_elements = remaining_elements.filter { |element| current_elements.include?(element.send(get_previous_element)) }
    end

    all_elements_in_order
  end
end
