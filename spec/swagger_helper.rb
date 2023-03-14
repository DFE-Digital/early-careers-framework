# frozen_string_literal: true

# source: https://github.com/DFE-Digital/teacher-training-api/blob/master/spec/swagger_helper.rb

require "rails_helper"

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{spec/docs}) do |metadata|
    metadata[:type] ||= :request
  end

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  swagger_v1_template = YAML.load_file(Rails.root.join("swagger/v1/template.yml"))
  swagger_v1_template["components"]["schemas"] ||= {}
  additional_component_schemas = Hash[
    Dir[Rails.root.join("swagger/v1/component_schemas/*.yml")].map do |path|
      component_name = File.basename(path, ".yml")
      [component_name, YAML.load_file(path)]
    end
  ]
  swagger_v1_template["components"]["schemas"].merge!(additional_component_schemas)
  swagger_v1_template["components"]["schemas"] = swagger_v1_template["components"]["schemas"].sort.to_h

  ###

  swagger_v2_template = YAML.load_file(Rails.root.join("swagger/v2/template.yml"))
  swagger_v2_template["components"]["schemas"] ||= {}
  additional_component_schemas = Hash[
    Dir[Rails.root.join("swagger/v2/component_schemas/*.yml")].map do |path|
      component_name = File.basename(path, ".yml")
      [component_name, YAML.load_file(path)]
    end
  ]
  swagger_v2_template["components"]["schemas"].merge!(additional_component_schemas)
  swagger_v2_template["components"]["schemas"] = swagger_v2_template["components"]["schemas"].sort.to_h

  ###

  swagger_v3_template = YAML.load_file(Rails.root.join("swagger/v3/template.yml"))
  swagger_v3_template["components"]["schemas"] ||= {}
  additional_component_schemas = Hash[
    Dir[Rails.root.join("swagger/v3/component_schemas/*.yml")].map do |path|
      component_name = File.basename(path, ".yml")
      [component_name, YAML.load_file(path)]
    end
  ]
  swagger_v3_template["components"]["schemas"].merge!(additional_component_schemas)
  swagger_v3_template["components"]["schemas"] = swagger_v3_template["components"]["schemas"].sort.to_h

  ###

  config.swagger_docs = {
    "v1/api_spec.json" => swagger_v1_template.with_indifferent_access,
    "v2/api_spec.json" => swagger_v2_template.with_indifferent_access,
    "v3/api_spec.json" => swagger_v3_template.with_indifferent_access,
  }
end

if defined?(Rswag::Specs)
  module Rswag
    module Specs
      module ExampleGroupHelpers
        # def schema(value, content_type: "application/json")
        #   content_hash = { content_type => { schema: value } }
        #   metadata[:response][:content] = content_hash
        # end
      end

      module ExampleGroupHelpersExtensions
        def curl_example(hash)
          metadata[:operation]["x-curl-examples"] ||= []
          metadata[:operation]["x-curl-examples"] << hash
        end
      end
    end
  end

  Rswag::Specs::ExampleGroupHelpers.include(Rswag::Specs::ExampleGroupHelpersExtensions)
end
