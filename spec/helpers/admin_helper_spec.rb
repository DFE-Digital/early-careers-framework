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

  context "using the induction record for ects and mentors", :with_default_schedules do
    let(:profile) { create(:ect) }
    let!(:induction_programme) { profile.current_induction_record.induction_programme }

    before do
      profile.current_induction_record.withdrawing!
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

  describe "#html_list" do
    let(:values) { %w[aaa bbb ccc ddd] }
    subject { html_list(values) }

    it "formats the provided values in a ul.govuk-list" do
      expect(subject).to have_css("ul.govuk-list > li", count: values.size)
      expect(values).to all(be_in(subject))
    end

    context "when nothing is passed in" do
      let(:values) { [] }

      it("renders nothing") { is_expected.to be_nil }
    end
  end
end
