# frozen_string_literal: true

describe Oneoffs::Migration::Match do
  let(:matches) { [OpenStruct.new(foo: :bar)].to_set }
  let(:instance) { described_class.new(matches) }

  it { expect(instance.matches).to eq(matches) }

  context "when matches is not a set" do
    let(:matches) { [OpenStruct.new(foo: :bar)] }

    it { expect { instance }.to raise_error(ArgumentError, "matches must be a Set") }
  end

  describe "#orphan" do
    subject(:orphan) { instance.orphan }

    context "when there is only one match" do
      it { is_expected.to eq(matches.first) }
    end

    context "when there is more than one match" do
      let(:matches) { Set[OpenStruct.new(foo: :bar), OpenStruct.new(foo: :baz)] }

      it { expect { orphan }.to raise_error(described_class::NotOrphanedError) }
    end

    context "when there are no matches" do
      let(:matches) { Set.new }

      it { expect { orphan }.to raise_error(described_class::NotOrphanedError) }
    end
  end

  describe "#orphaned?" do
    context "when there is only one match" do
      it { expect(instance.matches.size).to be(1) }
      it { expect(instance).to be_orphaned }
    end

    context "when there is more than one match" do
      let(:matches) { Set[OpenStruct.new(foo: :bar), OpenStruct.new(foo: :baz)] }

      it { expect(instance.matches.size).to be(2) }
      it { expect(instance).not_to be_orphaned }
    end
  end

  describe "#duplicated?" do
    context "when there is only one match" do
      it { expect(instance.matches.size).to be(1) }
      it { expect(instance).not_to be_duplicated }
    end

    context "when there are two matches" do
      let(:matches) { Set[OpenStruct.new(foo: :bar), OpenStruct.new(foo: :baz)] }

      it { expect(instance.matches.size).to be(2) }
      it { expect(instance).not_to be_duplicated }
    end

    context "when there are more than two matchs" do
      let(:matches) { Set[OpenStruct.new(foo: :bar), OpenStruct.new(foo: :baz), OpenStruct.new(baz: :bar)] }

      it { expect(instance.matches.size).to be(3) }
      it { expect(instance).to be_duplicated }
    end
  end
end
