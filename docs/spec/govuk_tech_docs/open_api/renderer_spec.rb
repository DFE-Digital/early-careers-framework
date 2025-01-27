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
        "/api/v3/statements": {
          get: {
            responses: {
              "200": {
                description: "statements description goes here",
                content: {
                  "application/json": {
                    schema: {
                      "$ref": "#/components/schemas/statements",
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
          statements: {
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
              { "$ref": "#/components/schemas/statementString" },
            ],
          },
          widgetInteger: {
            type: "object",
            properties: {
              id: { type: "integer", example: 12_345 },
            },
          },
          statementString: {
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
        expect(rendered).to have_css(".govuk-heading-l", text: "/api/v3/statements")
        expect(rendered).to have_css("#api-v3-statements-get-responses")
        expect(rendered).to have_css("#api-v3-statements-get-responses-examples")
        expect(rendered).to have_css("span.govuk-details__summary-text", text: "200 - statements description goes here")
      end

      it "renders schemas" do
        expect(rendered).to have_css("#schema-widget", text: "widget")
        expect(rendered).to have_link("widgetInteger", href: "#schema-widgetinteger")
        expect(rendered).to have_link("statementString", href: "#schema-statementstring")
      end
    end

    describe "ordering sidebar links" do
      let(:spec) do
        {
          openapi: "3.0.0",
          info: {
            title: "title",
            version: "0.0.1",
          },
          paths: {
            "/api/v3/schools": { get: { responses: {} } },
            "/api/v3/partnerships": { get: { responses: {} } },
            "/api/v3/participants": { get: { responses: {} } },
            "/api/v3/statements": { get: { responses: {} } },
            "/api/v3/unfunded-mentors": { get: { responses: {} } },
            "/api/v3/delivery-partners": { get: { responses: {} } },
            "/api/v3/participant-declarations/{id}": { get: { responses: {} } },
            "/api/v3/participant-declarations": { get: { responses: {} } },
            "/api/v3/participant-declarations.csv": { get: { responses: {} } },
          },
        }
      end

      subject(:rendered) do
        spec["servers"] = [
          { url: "https://example.com" },
        ]
        document = Openapi3Parser.load(spec)

        render = described_class.new(nil, document)
        Capybara::Node::Simple.new(render.api_full)
      end

      it "renders a sorted list of paths, by group and then length" do
        expected_order = [
          "/api/v3/delivery-partners",
          "/api/v3/partnerships",
          "/api/v3/schools",
          "/api/v3/participant-declarations",
          "/api/v3/participant-declarations.csv",
          "/api/v3/participant-declarations/{id}",
          "/api/v3/participants",
          "/api/v3/unfunded-mentors",
          "/api/v3/statements",
        ]

        rendered_paths = rendered.all(".govuk-heading-l").map(&:text).map(&:strip)

        expect(rendered_paths).to eq(expected_order)
      end

      context "when the sort order is not known for a path" do
        let(:spec) do
          {
            openapi: "3.0.0",
            info: {
              title: "title",
              version: "0.0.1",
            },
            paths: {
              "/api/v1/unknown": { get: { responses: {} } },
            },
          }
        end

        it { expect { rendered }.to raise_error("Unknown path group: unknown") }
      end
    end
  end
end
