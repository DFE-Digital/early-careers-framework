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

    context "with object given via for: keyword" do
      let(:object) { random_record }
      let(:other_object) { random_record }

      before { described_class.activate(feature_name, for: object) }

      it "enables the feature for given object" do
        expect(described_class.active?(feature_name, for: object)).to be true
      end

      it "does not enable the feature for other objects" do
        expect(described_class.active?(feature_name, for: other_object)).to be false
      end

      it "does not enable the feature globally" do
        expect(described_class.active?(feature_name)).to be false
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

      it "does not deactivate object based flags" do
        object = random_record
        described_class.activate(feature_name, for: object)

        expect { described_class.deactivate(feature_name) }
          .not_to change { described_class.active?(feature_name, for: object) }
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

      it "does deactivate all object based flags" do
        object = random_record
        described_class.activate(feature_name, for: object)

        expect { described_class.deactivate(feature_name, for: :all) }
          .to change { described_class.active?(feature_name, for: object) }.to false
      end
    end

    context "with object passed via for: keyword" do
      let(:object) { random_record }
      let(:other_object) { random_record }

      before do
        described_class.activate(feature_name, for: object)
        described_class.activate(feature_name, for: other_object)
      end

      it "does deactivate the feature for given object" do
        expect { described_class.deactivate(feature_name, for: object) }
          .to change { described_class.active?(feature_name, for: object) }.to false
      end

      it "does not deactivate the feature for other objects" do
        expect { described_class.deactivate(feature_name, for: object) }
          .not_to change { described_class.active?(feature_name, for: other_object) }
      end
    end
  end

  def random_record
    # TODO: WHY ARE SOME FACTORIES BROKEN?
    create FactoryBot.factories.map(&:name).without(:participant_band, :pupil_premium, :declarable, :profile_declaration, :npq_validation_data).sample
  end
end
