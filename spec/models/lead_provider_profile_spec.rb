# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderProfile, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:lead_provider) }
  end
end
