# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pages::TemplateResolver do
  let(:page) { "a/nested-page" }
  let(:page_template) { "pages/a/nested_page" }
  let(:lookup_context) { instance_double(ActionView::LookupContext) }
  let(:instance) { described_class.new(lookup_context) }

  before { allow(lookup_context).to receive(:template_exists?).with(page_template, [], false).and_return(template_exists) }

  describe "#resolve" do
    subject { instance.resolve(page) }

    context "when the template exists" do
      let(:template_exists) { true }

      it { is_expected.to eq(page_template) }
    end

    context "when the template does not exist" do
      let(:template_exists) { false }

      it { is_expected.to be_nil }
    end
  end
end
