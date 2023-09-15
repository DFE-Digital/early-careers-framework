# frozen_string_literal: true

require "rails_helper"

RSpec.describe NameMatcher do
  names = {
    ["Miss Allison Taylor", "Ms Allison Page"]  => [true, false],
    ["Miss Allison Taylor", "Allison Taylor"]  => [true, true],
    ["Mr Allison Taylor", "Mr Allison Page"]  => [true, false],
    ["Mr Allison Taylor", "Allison Taylor"]  => [true, true],
    ["rev Allison Taylor", "Prof. Allison Page"]  => [true, false],
    ["Dr. Allison Taylor", "Allison Taylor"]  => [true, true],
    ["Allison Taylor", "Prof. Allison Taylor"]  => [true, true],
    ["Dr. Nicola Taylor", "Allison Taylor"]  => [false, false],
  }

  names.each do |input, output|
    context "#{input.first}, #{input.last}" do
      let(:name_1) { input.first }
      let(:name_2) { input.last }

      subject { described_class.new(name_1, name_2, check_first_name_only:).matches? }

      context "when first name check" do
        let(:check_first_name_only) { true }

        it "returns #{output.first}" do
          expect(subject).to be(output.first)
        end
      end

      context "when full name check" do
        let(:check_first_name_only) { false }

        it "returns #{output.last}" do
          expect(subject).to be(output.last)
        end
      end
    end
  end
end
