# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderPolicy, type: :policy do
  subject { described_class.new(user, lead_provider) }

  let(:lead_provider) { create(:lead_provider) }

  context "being an admin" do
    let(:user) { create(:admin_profile).user }

    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
  end

  context "not being an admin" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
  end
end
