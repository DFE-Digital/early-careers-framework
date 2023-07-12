# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Adjustment, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:statement) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:payment_type) }
  end
end
