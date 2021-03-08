# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminHelper, type: :helper do
  let(:user) { profile.user }

  describe "#admin_edit_user_path" do
    context "when the user is a lead provider" do
      let(:profile) { create(:lead_provider_profile) }
      let(:result) { "/admin/lead-providers/users/#{user.id}/edit" }

      it "returns the admin edit url for the user" do
        expect(helper.admin_edit_user_path(user)).to eq(result)
      end
    end

    context "when the user is an induction coordinator" do
      let(:profile) { create(:induction_coordinator_profile) }
      let(:result) { "/admin/induction-coordinators/#{user.id}/edit" }

      it "returns the admin edit url for the user" do
        expect(helper.admin_edit_user_path(user)).to eq(result)
      end
    end
  end
end
