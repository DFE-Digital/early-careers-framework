# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinanceProfilePolicy, type: :policy do
  subject { described_class.new(user, finance_profile) }
  let(:finance_profile) { create(:finance_profile) }

  context "being a finance" do
    let(:user) { create(:user, :finance) }

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
