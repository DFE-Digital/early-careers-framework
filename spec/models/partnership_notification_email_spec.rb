# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipNotificationEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:partnerable) }
    it { is_expected.to have_one(:nomination_email) }
    it { is_expected.to delegate_method(:school).to(:partnerable) }
    it { is_expected.to delegate_method(:lead_provider).to(:partnerable) }
    it { is_expected.to delegate_method(:delivery_partner).to(:partnerable).allow_nil }
    it { is_expected.to delegate_method(:cohort).to(:partnerable) }
    it { is_expected.to delegate_method(:challenge_deadline).to(:partnerable) }
  end
end
