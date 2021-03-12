# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipPolicy, type: :policy do
  subject { described_class.new(user, partnership) }

  let(:partnership) { create(:partnership) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
  end

  context "not being an admin" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:update) }
  end
end
