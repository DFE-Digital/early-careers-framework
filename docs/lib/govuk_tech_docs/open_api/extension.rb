# frozen_string_literal: true

require "openapi3_parser"
require "uri"
require_relative "renderer"

module GovukTechDocs
  module OpenApi
    class Extension < Middleman::Extension
      expose_to_application api: :api

      def initialize(app, options_hash = {}, &block)
        super

        @app = app
        @config = @app.config[:tech_docs]
        @document = Openapi3Parser.load_file(api_path)
        @render = Renderer.new(@app, @document)
      end

      def api(text)
        keywords = {
          "api&gt;" => "default",
          "api_schema&gt;" => "schema",
        }

        regexp = keywords.map { |k, _| Regexp.escape(k) }.join("|")

        md = text.match(/^<p>(#{regexp})/)

        if md
          key = md.captures[0]
          type = keywords[key]

          text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

          # Strip paragraph tags from text
          text = text.gsub(/<\/?[^>]*>/, "")
          text = text.strip

          if text == "api&gt;"
            @render.api_full
          elsif type == "default"
            output = @render.path(text)
            # Render any schemas referenced in the above path
            output += @render.schemas_from_path(text)
            output
          else
            @render.schema(text)
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

      def api_path
        @config["open_api_path"].to_s
      end
    end
  end
end

::Middleman::Extensions.register(:open_api, GovukTechDocs::OpenApi::Extension)
