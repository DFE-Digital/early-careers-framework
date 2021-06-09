# frozen_string_literal: true

module JsonSchema
  class VersionedSchemaReader < ::JSON::Schema::Reader
    def read(schema_uri)
      super(::JSON::Util::URI.normalized_uri(uri_to_file(schema_uri.path)))
    end

  private

    attr_reader :version

    def initialize(version: 1.0, options: {})
      @version = version
      super(options)
    end

    def uri_to_file(uri_from_schema)
      uri_from_schema.gsub("/schema/", Rails.root.join("etc/schema/#{version}/").to_s)
    end
  end
end
