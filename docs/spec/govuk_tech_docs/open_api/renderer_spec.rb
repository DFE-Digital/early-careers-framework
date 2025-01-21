# frozen_string_literal: true

require "capybara/rspec"
require "openapi3_parser"
require "govuk_tech_docs/open_api/renderer"

RSpec.describe GovukTechDocs::OpenApi::Renderer do
  let(:spec) do
    {
      openapi: "3.0.0",
      info: {
        title: "title",
        version: "0.0.1",
      },
      paths: {
        "/widgets": {
          get: {
            responses: {
              "200": {
                description: "widgets description goes here",
                content: {
                  "application/json": {
                    schema: {
                      "$ref": "#/components/schemas/widgets",
                    },
                  },
                },
              },
            },
          },
        },
      },
      components: {
        schemas: {
          widgets: {
            properties: {
              data: {
                type: "array",
                items: {
                  "$ref": "#/components/schemas/widget",
                },
              },
            },
          },
          widget: {
            anyOf: [
              { "$ref": "#/components/schemas/widgetInteger" },
              { "$ref": "#/components/schemas/widgetString" },
            ],
          },
          widgetInteger: {
            type: "object",
            properties: {
              id: { type: "integer", example: 12_345 },
            },
          },
          widgetString: {
            type: "object",
            properties: {
              id: { type: "string", example: "abcde" },
            },
          },
        },
      },
    }
  end

  describe "#api_full" do
    it "renders a server with no description" do
      spec["servers"] = [
        { url: "https://example.com" },
      ]
      document = Openapi3Parser.load(spec)

      render = described_class.new(nil, document)
      rendered = Capybara::Node::Simple.new(render.api_full)

      expect(rendered).to have_css("h2#servers")
      expect(rendered).to have_css("div#server-list>a", text: "https://example.com")
      expect(rendered).not_to have_css("div#server-list>p")
    end

    it "renders a list of servers" do
      spec["servers"] = [
        { url: "https://example.com", description: "Production" },
        { url: "https://dev.example.com", description: "Development" },
      ]
      document = Openapi3Parser.load(spec)

      render = described_class.new(nil, document)
      rendered = Capybara::Node::Simple.new(render.api_full)

      expect(rendered).to have_css("h2#servers")
      expect(rendered).to have_css("div#server-list>a", text: "https://example.com")
      expect(rendered).to have_css("div#server-list>p>strong", text: "Production")
      expect(rendered).to have_css("div#server-list>a", text: "https://dev.example.com")
      expect(rendered).to have_css("div#server-list>p>strong", text: "Development")
    end

    describe "rendering API content" do
      subject(:rendered) do
        spec["servers"] = [
          { url: "https://example.com" },
        ]
        document = Openapi3Parser.load(spec)

        render = described_class.new(nil, document)
        Capybara::Node::Simple.new(render.api_full)
      end

      it "renders a list of paths" do
        expect(rendered).to have_css(".govuk-heading-l", text: "/widgets")
        expect(rendered).to have_css("#widgets-get-responses")
        expect(rendered).to have_css("#widgets-get-responses-examples")
        expect(rendered).to have_css("span.govuk-details__summary-text", text: "200 - widgets description goes here")
      end

      it "renders schemas" do
        expect(rendered).to have_css("#schema-widget", text: "widget")
        expect(rendered).to have_link("widgetInteger", href: "#schema-widgetinteger")
        expect(rendered).to have_link("widgetString", href: "#schema-widgetstring")
      end
    end
  end
end
