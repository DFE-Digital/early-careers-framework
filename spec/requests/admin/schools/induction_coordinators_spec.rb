# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::InductionCoodinators", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/induction-coordinators/new" do
    it "renders the new template" do
      get "/admin/schools/#{school.id}/induction-coordinators/new"

      expect(response.body).to include(CGI.escapeHTML("Induction tutor for #{school.name}"))
      expect(response).to render_template("admin/schools/induction_coordinators/new")
    end
  end

  describe "POST /admin/schools/:school_id/induction-coordinators" do
    it "creates the induction tutor and redirects to admin/schools#show" do
      form_params = {
        nominate_induction_tutor_form: {
          full_name: "jo",
          email: "jo@example.com",
        },
      }
      post admin_school_induction_coordinators_path(school.id), params: form_params

      created_user = User.order(:created_at).last
      expect(created_user.full_name).to eq "jo"
      expect(created_user.email).to eq "jo@example.com"
      expect(created_user.induction_coordinator?).to be_truthy
      expect(response).to redirect_to admin_school_path(school.id)
    end
  end
end
