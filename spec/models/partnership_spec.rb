# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnership, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:delivery_partner) }
    it { is_expected.to have_many(:partnership_notification_emails) }
  end
end
