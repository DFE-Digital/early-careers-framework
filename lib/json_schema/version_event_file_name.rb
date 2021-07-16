# frozen_string_literal: true

module JsonSchema
  class VersionEventFileName
    class << self
      def call(schema_root: "etc/schema", schema_path: "participant_declarations", schema_file: "request_schema.json", version: "0.3", event: :create)
        new(schema_path: schema_path, schema_root: schema_root, schema_file: schema_file).call(version: version, event: event)
      end
    end

    def call(version:, event:)
      Rails.root.join(@schema_root, version.to_s, @schema_path, event.to_s, @schema_file)
    end

  private

    def initialize(schema_root: "etc/schema", schema_path: "participant_declarations", schema_file: "request_schema.json")
      @schema_root = schema_root
      @schema_path = schema_path
      @schema_file = schema_file
    end
  end
end
