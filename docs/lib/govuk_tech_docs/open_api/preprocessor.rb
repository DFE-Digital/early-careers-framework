# frozen_string_literal: true

class Hash
  def bury(*keys, value)
    if keys.length > 1
      self[keys.shift].bury(*keys, value)
    else
      self[keys.first] = value
    end
  end

  def deep_search(term:, path: [])
    each do |key, value|
      if value.is_a?(Hash)
        # Check for matching key.
        return path + [key] if key.to_s.downcase.include?(term)

        # Search values.
        match = value.deep_search(term:, path: path + [key])
        return match if match
      elsif value.to_s.downcase.include?(term)
        return path + [key]
      end
    end

    nil
  end
end

module GovukTechDocs
  module OpenApi
    class Preprocessor
      attr_reader :swagger_path

      def initialize(swagger_path)
        @swagger_path = swagger_path
      end

      def preprocess!
        remove_npq_references!
      end

    private

      def remove_npq_references!
        return unless ENV["REMOVE_NPQ_REFERENCES"].to_s == "true"

        swagger_file = File.read(swagger_path)
        return unless swagger_file.include?("npq")

        swagger_doc = JSON.parse(swagger_file, symbolize_names: true)

        # Remove NPQ references (limit to 100 to avoid infinite loop).
        1_000.times do
          keys = swagger_doc.deep_search(term: "npq")
          break if keys.blank?

          value = swagger_doc.dig(*keys)

          # Delete any keys that contain NPQ.
          if keys.last.to_s.downcase.include?("npq")
            swagger_doc.dig(*(keys[0...-1])).delete(keys.last)
          else
            # Delete any NPQ-specific values.
            case keys.last
            when :oneOf, :anyOf
              # Remove $ref values that contain NPQ.
              swagger_doc.bury(*keys, value.reject { |v| v[:$ref].downcase.include?("npq") })
            when :enum
              # Remove enum values that contain NPQ.
              swagger_doc.bury(*keys, value.reject { |v| v.downcase.include?("npq") })
            when :description
              # Remove schemas where the description contains NPQ (e.g. ChangeFundedPlaceDataRequest).
              if keys[1] == :schemas
                swagger_doc.dig(*keys.first(2)).delete(keys[2])
              # Change references of "ECF or NPQ" to just "ECF".
              elsif value.include?("ecf or npq")
                swagger_doc.bury(*keys, value.gsub(/ecf or npq/i, "ECF"))
              else
                raise "Unexpected description structure: #{keys}"
              end
            else
              raise "Unhandled keys: #{keys}"
            end
          end
        end

        raise "NPQ references still present in #{swagger_path}" if swagger_doc.to_s.include?("npq")

        File.open(swagger_path, "w") { |f| f.write(JSON.pretty_generate(swagger_doc)) }
      end
    end
  end
end
