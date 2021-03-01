# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipPolicy, type: :policy do
  subject { described_class.new(user, partnership) }

  let(:partnership) { create(:partnership) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_new_and_create_actions }
  end

  context "being a lead provider user" do
    let(:user) { create(:user, :lead_provider) }

    it { is_expected.to permit_new_and_create_actions }
  end

  context "not being an admin or lead provider user" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
  end
end
