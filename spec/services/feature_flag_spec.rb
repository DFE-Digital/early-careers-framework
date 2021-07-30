# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlag do
  let(:feature_name) { Faker::Lorem.words(number: 3).join("_").to_sym }
  before do
    stub_const("FeatureFlag::FEATURES", { feature_name => described_class.new(name: feature_name) })
  end

  describe ".activate" do
    context "without for: keyword" do
      it "activates a feature globally" do
        expect { FeatureFlag.activate(feature_name) }.to(
          change { FeatureFlag.active?(feature_name) }.from(false).to(true),
        )
      end

      it "records the change in the database" do
        feature = Feature.create_or_find_by!(name: feature_name)
        feature.update!(active: false)

        expect { FeatureFlag.activate(feature_name) }.to(
          change { feature.reload.active }.from(false).to(true),
        )
      end

      it "enables the feature for all the object" do
        FeatureFlag.activate(feature_name)

        expect(described_class.active?(feature_name, for: double)).to be true
      end
    end
  end

  describe ".deactivate" do
    context "without :for keyword" do
      it "deactivates a feature" do
        FeatureFlag.activate(feature_name)
        expect { FeatureFlag.deactivate(feature_name) }.to(
          change { FeatureFlag.active?(feature_name) }.from(true).to(false),
        )
      end

      it "records the change in the database" do
        feature = Feature.create_or_find_by!(name: feature_name)
        feature.update!(active: true)

        expect { FeatureFlag.deactivate(feature_name) }.to(
          change { feature.reload.active }.from(true).to(false),
        )
      end
    end

    context "with for: :all" do
      it "deactivates a feature" do
        FeatureFlag.activate(feature_name)
        expect { FeatureFlag.deactivate(feature_name) }.to(
          change { FeatureFlag.active?(feature_name) }.from(true).to(false),
        )
      end

      it "records the change in the database" do
        feature = Feature.create_or_find_by!(name: feature_name)
        feature.update!(active: true)

        expect { FeatureFlag.deactivate(feature_name) }.to(
          change { feature.reload.active }.from(true).to(false),
        )
      end
    end
  end
end
