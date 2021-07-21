# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/presenters/api_docs/api_reference.rb

module ApiDocs
  class ApiReference
    attr_reader :document

    delegate :servers, to: :document

    def initialize(spec)
      @document = Openapi3Parser.load(spec)
    end

    def operations
      http_operations = document.paths.flat_map do |path_name, path|
        %w[get put post delete patch].map do |http_verb|
          operation = path.public_send(http_verb)
          next unless operation.is_a?(Openapi3Parser::Node::Operation)

          ApiDocs::ApiOperation.new(http_verb: http_verb, path_name: path_name, operation: operation)
        end
      end

      http_operations.compact
    end

    def schemas
      document.components.schemas.values.map do |schema|
        ApiDocs::ApiSchema.new(schema)
      end
    end

    def field_lengths_summary
      rows = flatten_hash(LeadProviderApiSpecification.as_hash)

      rows.reduce([]) do |arr, (field, length)|
        if field.include?("Length")
          arr << [field.gsub("components.schemas.", ""), length]
        else
          arr
        end
      end
    end

  private

    def flatten_hash(hash)
      hash.each_with_object({}) do |(key, value), return_hash|
        if value.is_a? Hash
          flatten_hash(value).each do |hash_key, hash_value|
            return_hash["#{key}.#{hash_key}"] = hash_value
          end
        else
          return_hash[key] = value
        end
      end
    end
  end
end
