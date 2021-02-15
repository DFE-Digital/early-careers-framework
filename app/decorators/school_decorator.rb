# frozen_string_literal: true

module Decorators
  class SchoolDecorator
    attr_reader :school

    delegate :id, :name, :address_line1, :address_line2, :address_line3, :address_line4, :postcode, to: :school

    def initialize(school)
      @school = school
    end

    def full_address_formatted
      [address_line1, address_line2, address_line3, address_line4, postcode].reject(&:blank?).join(", ")
    end
  end
end
