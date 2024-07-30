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
        "/npq-widgets": {
          get: {
            responses: {
              "200": {
                description: "npq widgets description goes here",
                content: {
                  "application/json": {
                    schema: {
                      "$ref": "#/components/schemas/npqWidgets",
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
          npqWidgets: {
            properties: {
              data: {
                type: "array",
                items: {
                  "$ref": "#/components/schemas/npqWidget",
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
          npqWidget: {
            anyOf: [
              { "$ref": "#/components/schemas/npqWidgetInteger" },
              { "$ref": "#/components/schemas/npqWidgetString" },
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
          npqWidgetInteger: {
            type: "object",
            properties: {
              id: { type: "integer", example: 12_345 },
            },
          },
          npqWidgetString: {
            type: "object",
            properties: {
              id: { type: "string", example: "abcde" },
            },
          },
          otherWidget: {
            type: "object",
            description: "an NPQ widget without npq in the schema name",
          },
          enumWidget: {
            type: "object",
            properties: {
              enum_attr: {
                type: "string",
                enum: %w[
                  value
                  NPQ-value
                ],
              },
              various: {
                anyOf: [
                  {
                    "$ref": "#/components/schemas/npqWidget",
                  },
                ],
              },
            },
          },
        },
      },
    }
  end

  describe "#api_full" do
    let(:remove_npq_references) { false }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("REMOVE_NPQ_REFERENCES").and_return(remove_npq_references)
    end

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

        expect(rendered).to have_css(".govuk-heading-l", text: "/npq-widgets")
        expect(rendered).to have_css("#npq-widgets-get-responses")
        expect(rendered).to have_css("#npq-widgets-get-responses-examples")
        expect(rendered).to have_css("span.govuk-details__summary-text", text: "200 - npq widgets description goes here")
      end

      it "renders schemas" do
        expect(rendered).to have_css("#schema-widget", text: "widget")
        expect(rendered).to have_link("widgetInteger", href: "#schema-widgetinteger")
        expect(rendered).to have_link("widgetString", href: "#schema-widgetstring")

        expect(rendered).to have_css("#schema-npqwidget", text: "npqWidget")
        expect(rendered).to have_link("npqWidgetInteger", href: "#schema-npqwidgetinteger")
        expect(rendered).to have_link("npqWidgetString", href: "#schema-npqwidgetstring")

        expect(rendered).to have_css("#schema-otherwidget", text: "otherWidget")
        expect(rendered).to have_link("npqWidget", href: "#schema-npqwidget")

        expect(rendered).to have_css("li", text: "NPQ-value")
      end

      context "whem removing NPQ references" do
        let(:remove_npq_references) { true }

        it "renders a list of paths, excluding any that contain 'npq'" do
          expect(rendered).to have_css(".govuk-heading-l", text: "/widgets")
          expect(rendered).to have_css("#widgets-get-responses")
          expect(rendered).to have_css("#widgets-get-responses-examples")
          expect(rendered).to have_css("span.govuk-details__summary-text", text: "200 - widgets description goes here")

          expect(rendered).not_to have_css(".govuk-heading-l", text: "/npq-widgets")
          expect(rendered).not_to have_css("#npq-widgets-get-responses")
          expect(rendered).not_to have_css("#npq-widgets-get-responses-examples")
          expect(rendered).not_to have_css("span.govuk-details__summary-text", text: "200 - npq widgets description goes here")
        end

        it "renders schemas, excluding any that contain 'npq'" do
          expect(rendered).to have_css("#schema-widget", text: "widget")
          expect(rendered).to have_link("widgetInteger", href: "#schema-widgetinteger")
          expect(rendered).to have_link("widgetString", href: "#schema-widgetstring")

          expect(rendered).not_to have_css("#schema-npqwidget", text: "npqWidget")
          expect(rendered).not_to have_link("npqWidgetInteger", href: "#schema-npqwidgetinteger")
          expect(rendered).not_to have_link("npqWidgetString", href: "#schema-npqwidgetstring")

          expect(rendered).not_to have_css("#schema-otherwidget", text: "otherWidget")
          expect(rendered).not_to have_link("npqWidget", href: "#schema-npqwidget")

          expect(rendered).not_to have_css("li", text: "NPQ-value")
        end
      end
    end
  end
end
