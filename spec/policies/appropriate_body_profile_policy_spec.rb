# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodyProfilePolicy, type: :policy do
  subject { described_class.new(user, appropriate_body_profile) }

  let(:appropriate_body_profile) { create(:appropriate_body_profile) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "not being an admin" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:index) }
  end
end
