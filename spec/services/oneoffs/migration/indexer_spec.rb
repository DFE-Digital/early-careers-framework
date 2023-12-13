# frozen_string_literal: true

describe Oneoffs::Migration::Indexer do
  let(:indexes) { %i[foo bar] }
  let(:objects) do
    [
      OpenStruct.new(foo: 1),
      OpenStruct.new(bar: 2),
      OpenStruct.new(foo: 1, bar: 3),
      OpenStruct.new(bar: 5),
      OpenStruct.new(foo: 4, bar: 5),
      OpenStruct.new(foo: 4),
    ]
  end
  let(:instance) { described_class.new(indexes, objects) }

  describe "#initialize" do
    context "when there are no indexes" do
      let(:indexes) { [] }

      it { expect { instance }.to raise_error(described_class::NoIndexesError, /specify indexes/) }
    end
  end

  describe "#lookup" do
    subject(:perform_lookup) { instance.lookup(obj) }

    context "when object is not in the index" do
      let(:obj) { OpenStruct.new(foo: :baz) }

      it { is_expected.to be_empty }
    end

    context "when an object only matches itself in the index" do
      let(:obj) { objects[1] }

      it { is_expected.to contain_exactly(obj) }
    end

    context "when an object matches other objects in the index" do
      let(:obj) { objects[0] }

      it { is_expected.to contain_exactly(objects[0], objects[2]) }
    end

    context "when an object matches can be inferred through common objects" do
      let(:obj) { objects[3] }

      it { is_expected.to contain_exactly(objects[3], objects[4], objects[5]) }
    end

    context "when an object cannot be indexed as it doesn't respond to any of the indexed attributes" do
      let(:obj) { OpenStruct.new(bar: :qux) }
      let(:objects) { [OpenStruct.new(baz: :qux)] }

      it { expect { perform_lookup }.to raise_error(described_class::UnindexableError, /unable to index/) }
    end

    context "when indexing on an array" do
      let(:indexes) { %i[foos] }
      let(:obj) { objects[0] }
      let(:objects) do
        [
          OpenStruct.new(foos: %i[bar]),
          OpenStruct.new(foos: %i[bar baz]),
          OpenStruct.new(foos: %i[baz]),
          OpenStruct.new(foos: %i[qux]),
        ]
      end

      it "indexes on array values individually (and performs the same inference)" do
        is_expected.to contain_exactly(objects[0], objects[1], objects[2])
      end
    end
  end
end
