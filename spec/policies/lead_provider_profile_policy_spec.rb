# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderProfilePolicy, type: :policy do
  subject { described_class.new(acting_user, lead_provider_profile) }

  let(:lead_provider_profile) { create(:lead_provider_profile) }

  context "being an admin" do
    let(:acting_user) { create(:user, :admin) }

    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
  end

  context "not being an admin" do
    let(:acting_user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
  end
end
