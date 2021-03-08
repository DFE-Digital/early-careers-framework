# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminProfilePolicy, type: :policy do
  subject { described_class.new(user, admin_profile) }

  let(:admin_profile) { create(:admin_profile) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_new_and_create_actions }
  end

  context "not being an admin" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
  end
end
