# frozen_string_literal: true

module OrderHelper
  def elements_in_order(elements:, previous_method_name:)
    first_elements = elements.filter { |element| !elements.include?(element.send(previous_method_name)) }
    return [] unless first_elements.any?

    strands = first_elements.map do |first_element|
      ordered_elements = [first_element]
      current_element = first_element
      next_element = elements.find { |element| element.send(previous_method_name) == current_element }

      while elements.include?(next_element)
        ordered_elements += [next_element]
        current_element = next_element
        next_element = elements.find { |element| element.send(previous_method_name) == current_element }
      end

      ordered_elements
    end

    strands.flatten
  end
end
