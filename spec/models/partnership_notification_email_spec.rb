# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipNotificationEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:partnership) }
    it { is_expected.to have_one(:nomination_email) }
    it { is_expected.to delegate_method(:school).to(:partnership) }
    it { is_expected.to delegate_method(:lead_provider).to(:partnership) }
    it { is_expected.to delegate_method(:delivery_partner).to(:partnership).allow_nil }
    it { is_expected.to delegate_method(:cohort).to(:partnership) }
    it { is_expected.to delegate_method(:challenge_deadline).to(:partnership) }
  end
end
