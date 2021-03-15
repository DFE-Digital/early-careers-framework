# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(acting_user, user_under_test) }

  let(:user_under_test) { create(:user) }

  context "being an admin" do
    let(:acting_user) { create(:user, :admin) }

    it { is_expected.to permit_new_and_create_actions }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }

    context "and attempting to delete its own record" do
      subject { described_class.new(acting_user, acting_user) }

      it "does not allow deletion" do
        expect(subject.destroy?).to eq false
      end
    end
  end

  context "not being an admin" do
    let(:acting_user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
  end
end
