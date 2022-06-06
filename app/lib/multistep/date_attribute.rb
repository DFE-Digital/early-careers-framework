# frozen_string_literal: true

module Multistep
  module DateAttribute
    extend ActiveSupport::Concern

  private

    def partial_date_assignments
      @partial_date_assignments ||= Hash.new { |h, k| h[k] = Array.new(3) }
    end

    module ClassMethods
      def attribute(name, **)
        super_result = super

        return super_result unless attribute_types[name.to_s].type == :date

        validate do
          errors.add(name, :invalid) if send(name).is_a? InvalidDate
        end

        (1..3).each do |number|
          define_method "#{name}(#{number}i)=" do |value|
            return if value.blank?

            values = partial_date_assignments[name]
            values[3 - number] = value

            date = if values.all?(&:present?)
                     begin
                       Date.parse(values.join("/"))
                     rescue Date::Error
                       InvalidDate.new(*values)
                     end
                   else
                     InvalidDate.new(*values)
                   end
            send("#{name}=", date)
          end
        end
      end
    end

    InvalidDate = Struct.new(:day, :month, :year)
  end
end
