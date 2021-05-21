# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::InductionCoodinators", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:induction_tutor) { create(:user, :induction_coordinator, full_name: "May Weather", email: "may.weather@school.org", schools: [school]) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/induction-coordinators/new" do
    it "renders the new template" do
      get "/admin/schools/#{school.id}/induction-coordinators/new"

      expect(response).to render_template("admin/schools/induction_coordinators/new")
    end
  end

  describe "POST /admin/schools/:school_id/induction-coordinators" do
    it "creates the induction tutor and redirects to admin/schools#show" do
      form_params = {
        tutor_details: {
          full_name: "jo",
          email: "jo@example.com",
        },
      }
      post admin_school_induction_coordinators_path(school), params: form_params

      created_user = User.order(:created_at).last
      expect(created_user.full_name).to eq "jo"
      expect(created_user.email).to eq "jo@example.com"
      expect(created_user.induction_coordinator?).to be_truthy
      expect(response).to redirect_to admin_school_path(school)
      expect(flash[:success][:content]).to eq "New induction tutor added. They will get an email with next steps."
    end
  end

  describe "GET /admin/schools/:school_id/induction-coordinators/:id/edit" do
    it "renders the edit template" do
      get "/admin/schools/#{school.id}/induction-coordinators/#{induction_tutor.id}/edit"

      expect(response).to render_template("admin/schools/induction_coordinators/edit")
      expect(assigns(:induction_tutor)).to eq induction_tutor
    end
  end

  describe "GET /admin/schools/:school_id/induction-coordinators/choose-replace-or-update" do
    it "renders the choose replace or update template" do
      get "/admin/schools/#{school.id}/induction-coordinators/choose-replace-or-update"

      expect(response).to render_template("admin/schools/induction_coordinators/choose_replace_or_update")
    end
  end

  describe "POST /admin/schools/:school_id/induction-coordinators/replace-or-update" do
    context "when 'replace' is selected" do
      it "redirects to the new induction coordinator method" do
        form_params = {
          replace_or_update_tutor_form: {
            choice: "replace",
          },
        }
        post "/admin/schools/#{school.id}/induction-coordinators/replace-or-update", params: form_params

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
        post "/admin/schools/#{school.id}/induction-coordinators/replace-or-update", params: form_params

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
        post "/admin/schools/#{school.id}/induction-coordinators/replace-or-update", params: form_params

        expect(response).to render_template("admin/schools/induction_coordinators/choose_replace_or_update")
      end
    end
  end

  describe "PATCH /admin/schools/:school_id/induction-coordinators/:id" do
    it "updates the induction tutor and redirects to admin/schools#show" do
      form_params = {
        tutor_details: {
          full_name: "Arthur Chigley",
          email: "arthur.chigley@example.com",
        },
      }
      patch admin_school_induction_coordinator_path(school.id, induction_tutor.id), params: form_params

      expect(response).to redirect_to admin_school_path(school.id)
      expect(flash[:success][:content]).to eq "Induction tutor details updated"
      induction_tutor.reload
      expect(induction_tutor.full_name).to eq "Arthur Chigley"
      expect(induction_tutor.email).to eq "arthur.chigley@example.com"
    end
  end
end
