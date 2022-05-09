# frozen_string_literal: true

require "rails_helper"

RSpec.describe TabLabelDecorator do
  let(:label) { "aBc 123" }
  subject(:decorator) { described_class.new(label) }

  describe "#parameterize" do
    it "acts like String#parameterize" do
      expect(decorator.parameterize).to eq label.parameterize
      expect(decorator.parameterize(separator: "%", preserve_case: true)).to eq label.parameterize(separator: "%", preserve_case: true)
    end

    context "when the label starts with a digit" do
      let(:label) { "2021-2022" }

      it "prefixes the result with an underscore" do
        expect(decorator.parameterize).to eq "_2021-2022"
      end
    end
  end
end
