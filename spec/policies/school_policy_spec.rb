# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolPolicy, type: :policy do
  subject { described_class.new(user, school) }

  let(:school) { create(:school) }

  let(:resolved_scope) do
    described_class::Scope.new(user, School.all).resolve
  end

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_actions(%i[index show]) }
    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }

    it "includes school in resolved scope" do
      expect(resolved_scope).to include(school)
    end

    context "when the school is not eligible" do
      let(:school) { create(:school, school_status_code: 2) }

      it "doesn't include ineligible schools in resolved scope" do
        expect(resolved_scope).not_to include(school)
      end
    end
  end

  context "not being an admin" do
    let(:user) { create(:user) }

    it { is_expected.to forbid_new_and_create_actions }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_actions(%i[index show destroy]) }

    it "includes no schools in resolved scope" do
      expect(resolved_scope.count).to eq 0
    end
  end
end
