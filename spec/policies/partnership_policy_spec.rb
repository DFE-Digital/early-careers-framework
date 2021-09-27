# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipPolicy, type: :policy do
  subject { described_class.new(user, partnership) }

  let(:user) { create(:user) }
  let(:partnership) { create :partnership }

  it { is_expected.to forbid_actions(%i[create show edit update]) }

  context "being an induction coordinator from the partnership school" do
    let(:user) { create(:user, :induction_coordinator, schools: [partnership.school]) }

    it { is_expected.to permit_actions(%i[update edit]) }
    it { is_expected.to forbid_actions(%i[create show]) }
  end

  context "being an induction coordinator from a different school" do
    let(:user) { create(:user, :induction_coordinator) }

    it { is_expected.to forbid_actions(%i[create show edit update]) }
  end

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_actions(%i[update edit]) }
    it { is_expected.to forbid_actions(%i[create show]) }
  end
end
