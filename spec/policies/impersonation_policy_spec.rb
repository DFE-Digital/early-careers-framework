# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImpersonationPolicy, type: :policy do
  subject { described_class.new(acting_user, user_under_test) }

  let(:user_under_test) { create(:user) }

  context "being an admin" do
    let(:acting_user) { create(:user, :admin) }

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }

    context "and attempting to impersonate its own record" do
      subject { described_class.new(acting_user, acting_user) }

      it "does not allow deletion" do
        expect(subject.create?).to eq false
      end
    end

    context "and attempting to impersonate another admin" do
      let(:another_admin) { create(:user, :admin) }
      subject { described_class.new(acting_user, another_admin) }

      it "does not allow deletion" do
        expect(subject.create?).to eq false
      end
    end
  end

  context "not being an admin" do
    let(:acting_user) { create(:user) }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
