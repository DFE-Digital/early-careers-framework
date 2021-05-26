# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::ReplaceOrUpdateInductionTutor", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:induction_tutor) { create(:user, :induction_coordinator, full_name: "May Weather", email: "may.weather@school.org", schools: [school]) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/replace-or-update-induction-tutor" do
    it "renders the show template" do
      get "/admin/schools/#{school.id}/replace-or-update-induction-tutor"

      expect(response).to render_template("admin/schools/replace_or_update_induction_tutor/show")
    end
  end

  describe "POST /admin/schools/:school_id/replace-or-update-induction-tutor" do
    context "when 'replace' is selected" do
      it "redirects to the new induction coordinator method" do
        form_params = {
          replace_or_update_tutor_form: {
            choice: "replace",
          },
        }
        post "/admin/schools/#{school.id}/replace-or-update-induction-tutor", params: form_params
        expect(response).to redirect_to new_admin_school_induction_coordinator_path(school)
      end
    end

    context "when 'update' is selected" do
      before do
        induction_tutor
      end

      it "redirects to the edit induction coordinator method" do
        form_params = {
          replace_or_update_tutor_form: {
            choice: "update",
          },
        }
        post "/admin/schools/#{school.id}/replace-or-update-induction-tutor", params: form_params

        expect(response).to redirect_to edit_admin_school_induction_coordinator_path(school, induction_tutor)
      end
    end

    context "when no choice is made" do
      it "renders the choose replace or update template" do
        form_params = {
          replace_or_update_tutor_form: {
            choice: "",
          },
        }
        post "/admin/schools/#{school.id}/replace-or-update-induction-tutor", params: form_params

        expect(response).to render_template("admin/schools/replace_or_update_induction_tutor/show")
      end
    end
  end
end
