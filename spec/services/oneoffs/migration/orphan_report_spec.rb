# frozen_string_literal: true

describe Oneoffs::Migration::OrphanReport do
  let(:indexes) { %i[foo bar] }
  let(:reconciler) { instance_double(Oneoffs::Migration::Reconciler, indexes:, orphaned_matches:) }
  let(:instance) { described_class.new(reconciler) }

  describe "#to_yaml" do
    subject { instance.to_yaml }

    context "when there are no orphans" do
      let(:orphaned_matches) { [] }

      it { is_expected.to eq([].to_yaml) }
    end

    context "when there are orphans" do
      let(:orphaned_matches) do
        [
          create_orphaned_match(foo: :baz, bar: :qux),
          create_orphaned_match(foo: :quux),
        ]
      end

      it "returns orphans and potential matches in YAML format" do
        is_expected.to eq(
          <<~YAML,
            ---
            - :orphan:
                :class: OpenStruct
                :foo: baz
                :bar: qux
              :potential_matches:
              - :class: OpenStruct
                :foo: baz
                :bar: qux
              - :class: OpenStruct
                :foo: baz
                :bar: qux
            - :orphan:
                :class: OpenStruct
                :foo: quux
              :potential_matches:
              - :class: OpenStruct
                :foo: quux
              - :class: OpenStruct
                :foo: quux
          YAML
        )
      end
    end
  end

  def create_orphaned_match(attributes)
    orphan = OpenStruct.new(attributes)
    potential_matches = 2.times.collect { OpenStruct.new(attributes) }
    Oneoffs::Migration::OrphanMatch.new(orphan, potential_matches)
  end
end
