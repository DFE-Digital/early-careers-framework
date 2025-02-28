# frozen_string_literal: true

require "markdown_renderer"

RSpec.describe MarkdownRenderer, type: :model do
  let(:context) { instance_double("Middleman::ConfigContext", app: nil) }

  let(:instance) { described_class.new(context:) }

  describe "#preprocess" do
    subject(:preprocess) { instance.preprocess(document) }

    described_class::TAG_MAPPINGS.each do |tag, color|
      context "when the document contains a #{tag} tag" do
        let(:document) { "[##{tag}]" }
        let(:expected_text) { tag.gsub("-", " ") }

        it { is_expected.to eq(%(<div class="tag-group"><strong class="govuk-tag govuk-tag--#{color}">#{expected_text}</strong></div>)) }
      end
    end

    context "when the document contains an unknown tag" do
      let(:document) { "[#unknown-tag]" }

      it { expect { preprocess }.to raise_error(described_class::UnknownTagError, "Tag not recognised: unknown-tag") }
    end

    context "when the tags are malformed (missing hash)" do
      let(:document) { "[#new feature]" }

      it { is_expected.to eq(document) }
    end

    context "when the tags are malformed (leading/trailing white space)" do
      let(:document) { "[ #new-feature ]" }

      it { is_expected.to eq(document) }
    end

    context "when the tags are in a different case" do
      let(:document) { "[#NeW-FeAtUrE]" }

      it { is_expected.to eq(%(<div class="tag-group"><strong class="govuk-tag govuk-tag--green">new feature</strong></div>)) }
    end

    context "when there are multiple sets of tags" do
      let(:document) { "[#new-feature][#bug-fix]" }

      it { is_expected.to eq(%(<div class="tag-group"><strong class="govuk-tag govuk-tag--green">new feature</strong></div><div class="tag-group"><strong class="govuk-tag govuk-tag--yellow">bug fix</strong></div>)) }
    end

    context "when there are multiple tags in the same group" do
      let(:document) { "[#new-feature #bug-fix]" }

      it { is_expected.to eq(%(<div class="tag-group"><strong class="govuk-tag govuk-tag--green">new feature</strong><strong class="govuk-tag govuk-tag--yellow">bug fix</strong></div>)) }
    end

    context "when there is other content mixed in with tags" do
      let(:document) { "[#bug-fix] [link](http://link.com)" }

      it { is_expected.to eq(%(<div class="tag-group"><strong class="govuk-tag govuk-tag--yellow">bug fix</strong></div> [link](http://link.com))) }
    end

    context "when the document contains multiple tags" do
      let(:tags) { described_class::TAG_MAPPINGS.keys.map { |key| "##{key}" } }
      let(:document) { "[#{tags.shuffle.join(' ')}]" }
      let(:rendered_tag_regex) { />([\w\s]+)</ }

      it "renders the tags in the correct order" do
        rendered_tags = preprocess.scan(rendered_tag_regex).flatten.map(&:parameterize)

        expect(rendered_tags).to eq(described_class::TAG_MAPPINGS.keys)
      end
    end
  end
end
