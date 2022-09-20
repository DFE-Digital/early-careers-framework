# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", :with_default_schedules, type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:old_date) { 2.weeks.ago.to_date }

  let!(:ect_profile) { create(:ect, induction_start_date: old_date) }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/change_induction_start_date/edit" do
    before { get("/admin/participants/#{ect_profile.id}/change_induction_start_date/edit") }

    it "renders the edit form for a participant's induction start date" do
      expect(response).to render_template("admin/participants/change_induction_start_date/edit")
      expect(response.body).to match(%r{<form.*action="/admin/participants/#{ect_profile.id}/change_induction_start_date"})
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end

    it "has the correct heading" do
      expect(response.body).to match(/What is #{ect_profile.user.full_name}.* new induction start date/)
    end
  end

  describe "GET /admin/participants/:participant_id/change_induction_start_date" do
    let(:new_date) { 3.weeks.from_now.to_date }

    # Rails multiparameter attributes for dates:
    let(:params) do
      {
        admin_participants_change_induction_start_date_form: {
          "induction_start_date(3i)" => new_date.day,
          "induction_start_date(2i)" => new_date.month,
          "induction_start_date(1i)" => new_date.year,
        },
      }
    end

    it "updates the induction_start_date for the given profile" do
      expect(ect_profile.induction_start_date).to eql(old_date)

      put("/admin/participants/#{ect_profile.id}/change_induction_start_date", params:)

      expect(ect_profile.reload.induction_start_date).to eql(new_date)
    end

    context "when invalid" do
      let(:params) do
        {
          admin_participants_change_induction_start_date_form: {
            "induction_start_date(3i)" => "",
            "induction_start_date(2i)" => "",
            "induction_start_date(1i)" => "",
          },
        }
      end

      it "renders :edit" do
        put("/admin/participants/#{ect_profile.id}/change_induction_start_date", params:)

        expect(response).to render_template("admin/participants/change_induction_start_date/edit")
      end
    end
  end
end
