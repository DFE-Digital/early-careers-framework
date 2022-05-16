# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerProfilePolicy, type: :policy do
  subject { described_class.new(user, delivery_partner_profile) }

  let(:delivery_partner_profile) { create(:delivery_partner_profile) }

  context "being a delivery_partner" do
    let(:user) { create(:user, :delivery_partner) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
  end

  context "not being a finance" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:index) }
  end
end
