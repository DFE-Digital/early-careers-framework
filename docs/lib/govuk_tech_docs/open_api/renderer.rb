# frozen_string_literal: true

require "erb"
require "json"
require "rouge"

module GovukTechDocs
  module OpenApi
    class Renderer
      attr_reader :app, :document

      def initialize(app, document)
        @app = app
        @document = document

        # Load template files
        @template_api_full = get_renderer("api_reference_full.html.erb")
        @template_path = get_renderer("path.html.erb")
        @template_schema = get_renderer("schema.html.erb")
        @template_operation = get_renderer("operation.html.erb")
        @template_parameters = get_renderer("parameters.html.erb")
        @template_request_body = get_renderer("request_body.html.erb")
        @template_responses = get_renderer("responses.html.erb")
        @template_any_of = get_renderer("any_of.html.erb")
        @template_one_of = get_renderer("one_of.html.erb")
        @template_curl_examples = get_renderer("curl_examples.html.erb")
      end

      def api_full
        paths = @document.paths.keys.inject("") do |memo, text|
          memo + path(text)
        end

        schema_names = @document.components.schemas.keys
        schemas = schema_names.inject("") do |memo, schema_name|
          memo + schema(schema_name)
        end

        @template_api_full.result(binding)
      end

      def path(text)
        path = @document.paths[text]
        id = text.parameterize
        operations = operations(text:, path:, path_id: id)
        @template_path.result(binding)
      end

      def schema(title)
        schema_data = schemas_data.find { |s| s[0] == title }
        schema = schema_data[1]

        properties = properties_for_schema(schema)

        if schema["anyOf"]
          @template_any_of.result(binding)
        elsif schema["oneOf"]
          @template_one_of.result(binding)
        else
          @template_schema.result(binding)
        end
      end

      def schemas_from_path(text)
        operations = get_operations(@document.paths[text])
        schemas = operations.flat_map do |_, operation|
          operation.responses.inject([]) do |memo, (_, response)|
            next memo unless response.content["application/json"]

            schema = response.content["application/json"].schema

            memo << schema.name if schema.name
            memo + schemas_from_schema(schema)
          end
        end

        # Render all referenced schemas
        output = schemas.uniq.inject("") do |memo, schema_name|
          memo + schema(schema_name)
        end

        output.prepend('<h2 id="schemas">Schemas</h2>') unless output.empty?
        output
      end

      def schemas_from_schema(schema)
        schemas = schema.properties.map(&:last)
        schemas << schema.items if schema.items && schema.type == "array"
        schemas += schema.all_of.to_a.flat_map { |s| s.properties.map(&:last) }

        schemas.flat_map do |nested|
          sub_schemas = schemas_from_schema(nested)
          nested.name ? [nested.name] + sub_schemas : sub_schemas
        end
      end

      def operations(text:, path:, path_id:)
        get_operations(path).compact.inject("") do |memo, (key, operation)|
          id = "#{path_id}-#{key.parameterize}"
          text = text # rubocop:disable Lint/SelfAssignment
          parameters = parameters(operation, id)
          request_body = request_body(operation, id) if operation.request_body
          responses = responses(operation, id)
          curl_examples = curl_examples(operation, id)
          memo + @template_operation.result(binding)
        end
      end

      def parameters(operation, operation_id)
        parameters = operation.parameters
        id = "#{operation_id}-parameters"
        @template_parameters.result(binding)
      end

      def request_body(operation, operation_id)
        request_body = operation.request_body
        id = "#{operation_id}-request_body"
        @template_request_body.result(binding)
      end

      def curl_examples(operation, operation_id)
        curl_examples = operation.node_data["x-curl-examples"] || []
        id = "#{operation_id}-curl-examples"
        @template_curl_examples.result(binding)
      end

      def responses(operation, operation_id)
        responses = operation.responses
        id = "#{operation_id}-responses"
        @template_responses.result(binding)
      end

      def markdown(text)
        if text
          Tilt["markdown"].new(context: @app) { text }.render
        end
      end

      def json_output(schema)
        properties = schema_properties(schema)
        JSON.pretty_generate(properties)
      end

      def json_prettyprint(data)
        JSON.pretty_generate(data)
      end

      def schema_properties(schema_data)
        properties = schema_data.properties.to_h
        schema_data.all_of.to_a.each do |all_of_schema|
          properties.merge!(all_of_schema.properties.to_h)
        end
        schema_data.any_of.to_a.each do |any_of_schema|
          properties.merge!(any_of_schema.properties.to_h)
        end

        properties.transform_values do |property|
          case property.type
          when "object"
            schema_properties(property.items || property)
          when "array"
            property.items ? [schema_properties(property.items)] : []
          else
            property.example || property.type
          end
        end
      end

      def schema_is_referenced?(schema)
        schema.node_context.source_location.pointer.segments[0..1] == %w[components schemas]
      end

    private

      def info
        document.info
      end

      def servers
        document.servers
      end

      def get_renderer(file)
        template_path = File.join(File.dirname(__FILE__), "templates/#{file}")
        template = File.open(template_path, "r").read
        ERB.new(template)
      end

      def get_operations(path)
        {
          "get" => path.get,
          "put" => path.put,
          "post" => path.post,
          "delete" => path.delete,
          "patch" => path.patch,
        }.compact
      end

      def get_schema_name(text)
        unless text.is_a?(String)
          return nil
        end

        # Schema dictates that it's always components['schemas']
        text.gsub(/#\/components\/schemas\//, "").gsub("/properties/data", "")
      end

      def get_schema_link_data(schema)
        schemas_from_schema(schema).each do |s|
          unless s.nil?
            id = "schema-#{s.parameterize}"
            return "<a href='\##{id}'>#{s}</a>"
          end
        end
      end

      def get_schema_link(schema)
        schema_name = if schema.is_a?(Openapi3Parser::Node::Schema)
                        get_schema_name(schema.node_context.source_location.to_s)
                      else
                        get_schema_name(schema.node.node_context.source_location.to_s)
                      end

        unless schema_name.nil?
          id = "schema-#{schema_name.parameterize}"
          "<a href='\##{id}'>#{schema_name}</a>"
        end
      end

      def schemas_data
        @schemas_data ||= @document.components.schemas
      end

      def format_possible_value(possible_value)
        if possible_value == ""
          "<em>empty string</em>"
        else
          possible_value
        end
      end

      def properties_for_schema(schema)
        properties = []

        schema["allOf"]&.each do |schema_nested|
          schema_nested.properties.each do |property|
            properties.push property
          end
        end

        schema["anyOf"]&.each do |schema_nested|
          schema_nested.properties.each do |property|
            properties.push property
          end
        end

        schema.properties.each do |property|
          properties.push property
        end

        if schema && schema.type == "array"
          properties.push ["Item", schema.items]
        end

        properties
      end
    end
  end
end
