# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlag do
  describe ".activate" do
    it "activates a feature" do
      expect { FeatureFlag.activate(:add_participants) }.to(
        change { FeatureFlag.active?(:add_participants) }.from(false).to(true),
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
  end
end
