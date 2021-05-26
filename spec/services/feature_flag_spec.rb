# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlag do
  describe ".activate" do
    it "activates a feature" do
      expect { FeatureFlag.activate(:add_participants) }.to(
        change { FeatureFlag.active?(:add_participants) }.from(false).to(true),
      )
    end

    it "records the change in the database" do
      feature = Feature.create_or_find_by!(name: "add_participants")
      feature.update!(active: false)
      expect { FeatureFlag.activate(:add_participants) }.to(
        change { feature.reload.active }.from(false).to(true),
      )
    end
  end

  describe ".deactivate" do
    it "deactivates a feature" do
      FeatureFlag.activate(:add_participants)
      expect { FeatureFlag.deactivate(:add_participants) }.to(
        change { FeatureFlag.active?(:add_participants) }.from(true).to(false),
      )
    end

    it "records the change in the database" do
      feature = Feature.create_or_find_by!(name: "add_participants")
      feature.update!(active: true)
      expect { FeatureFlag.deactivate(:add_participants) }.to(
        change { feature.reload.active }.from(true).to(false),
      )
    end
  end
end
