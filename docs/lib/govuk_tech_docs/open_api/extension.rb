# frozen_string_literal: true

require "openapi3_parser"
require "uri"
require_relative "renderer"

module GovukTechDocs
  module OpenApi
    class Loader
      def initialize(app:, path_to_spec:)
        @app = app
        @path_to_spec = path_to_spec
      end

      def renderer
        Renderer.new(app, document)
      end

    private

      attr_reader :app, :path_to_spec

      def document
        @document ||= Openapi3Parser.load_file(path_to_spec)
      end
    end

    class Extension < Middleman::Extension
      expose_to_application api: :api

      attr_reader :app

      def initialize(app, options_hash = {}, &block)
        super

        @app = app
      end

      def api(text)
        keywords = {
          "api&gt;" => "default",
          "api_schema&gt;" => "schema",
        }

        regexp = keywords.map { |k, _| Regexp.escape(k) }.join("|")

        md = text.match(/^<p>(#{regexp})(.*)<\/p>/)

        if md
          api_path = md.captures[1]

          key = md.captures[0]
          type = keywords[key]

          text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

          # Strip paragraph tags from text
          text = text.gsub(/<\/?[^>]*>/, "")
          text = text.strip

          loader = Loader.new(app: @app, path_to_spec: api_path)

          if api_path.present?
            loader.renderer.api_full
          elsif type == "default"
            output = loader.renderer.path(text)
            # Render any schemas referenced in the above path
            output += loader.renderer.schemas_from_path(text)
            output
          else
            loader.renderer.schema(text)
          end
        else
          text
        end
      end

    private

      def uri?(string)
        uri = URI.parse(string)
        %w[http https].include?(uri.scheme)
      rescue URI::BadURIError
        false
      rescue URI::InvalidURIError
        false
      end
    end
  end
end

::Middleman::Extensions.register(:open_api, GovukTechDocs::OpenApi::Extension)
