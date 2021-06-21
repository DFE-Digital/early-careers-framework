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

    context "when an induction tutor already exists with that email address" do
      let!(:existing_induction_coordinator) { create(:user, :induction_coordinator) }

      it "adds the school to their list of school" do
        expect {
          post admin_school_induction_coordinators_path(school), params: {
            tutor_details: {
              full_name: existing_induction_coordinator.full_name,
              email: existing_induction_coordinator.email,
            },
          }
        }.not_to change { User.count }

        expect(existing_induction_coordinator.schools.count).to eql 2
        expect(existing_induction_coordinator.schools).to include school
        expect(response).to redirect_to admin_school_path(school)
      end

      it "renders name_different when the name is different" do
        expect {
          post admin_school_induction_coordinators_path(school), params: {
            tutor_details: {
              full_name: "Different Name",
              email: existing_induction_coordinator.email,
            },
          }
        }.not_to change { User.count }

        expect(existing_induction_coordinator.schools.count).to eql 1
        expect(existing_induction_coordinator.schools).not_to include school
        expect(response).to render_template :name_different
      end
    end

    context "when a different user type already exists with that email address" do
      let!(:existing_user) { create(:user) }

      it "renders to email_used" do
        expect {
          post admin_school_induction_coordinators_path(school), params: {
            tutor_details: {
              full_name: name,
              email: existing_user.email,
            },
          }
        }.not_to change { User.count }

        expect(response).to render_template :email_used
      end
    end
  end

  describe "GET /admin/schools/:school_id/induction-coordinators/:id/edit" do
    before do
      induction_tutor
    end

    it "renders the edit template" do
      get "/admin/schools/#{school.id}/induction-coordinators/#{induction_tutor.id}/edit"

      expect(response).to render_template("admin/schools/induction_coordinators/edit")
      expect(assigns(:induction_tutor_form).user_id).to eq induction_tutor.id
      expect(assigns(:induction_tutor_form).email).to eq induction_tutor.email
      expect(assigns(:induction_tutor_form).full_name).to eq induction_tutor.full_name
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
      patch admin_school_induction_coordinator_path(school, induction_tutor.id), params: form_params

      expect(response).to redirect_to admin_school_path(school)
      expect(flash[:success][:content]).to eq "Induction tutor details updated"
      induction_tutor.reload
      expect(induction_tutor.full_name).to eq "Arthur Chigley"
      expect(induction_tutor.email).to eq "arthur.chigley@example.com"
    end
  end
end
