# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminHelper, type: :helper do
  let(:user) { profile.user }

  describe "#admin_edit_user_path" do
    context "when the user is a lead provider" do
      let(:profile) { create(:lead_provider_profile) }
      let(:result) { "/admin/suppliers/lead-providers/users/#{user.id}/edit" }

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

  context "using the induction record for ects and mentors" do
    let(:profile) { create(:ect_participant_profile) }
    let(:induction_programme) { create(:induction_programme) }

    before do
      first_record = Induction::Enrol.call(participant_profile: profile, induction_programme:)
      first_record.withdrawing!
      Induction::Enrol.call(participant_profile: profile, induction_programme:, preferred_email: "login2@example.com")
    end

    describe "#all_emails_associated_with_a_user" do
      it "returns all emails associated with a user" do
        latest_induction_record = profile.induction_records.active.latest
        users_emails = helper.all_emails_associated_with_a_user(latest_induction_record)
        expect(users_emails).to include(user.email)
        expect(users_emails).to include("login2@example.com")
      end
    end
  end
end
