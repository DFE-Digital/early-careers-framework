# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools", type: :request do
  before do
    user = create(:user, :admin)
    sign_in user
  end

  describe "GET /admin/schools" do
    it "renders the schools template" do
      get "/admin/schools"

      expect(response).to render_template("admin/schools/index")
    end

    it "only displays eligible and cip_only schools" do
      eligible_school = create(:school)
      closed_school = create(:school, school_status_code: 2)
      cip_only_school = create(:school, :cip_only)

      get "/admin/schools"
      expect(response.body).to include(eligible_school.urn)
      expect(response.body).to include(cip_only_school.urn)
      expect(response.body).not_to include(closed_school.urn)
    end

    context "filtering the school list" do
      let!(:included_school) { create(:school, name: "Include Me", urn: "090120") }
      let!(:excluded_school) { create(:school, name: "Exclude Me", urn: "333333") }

      it "filters the list of schools by name" do
        get "/admin/schools", params: { query: "include" }
        expect(assigns(:schools)).to match_array [included_school]
      end

      it "filters the list of schools by urn" do
        get "/admin/schools", params: { query: "901" }
        expect(assigns(:schools)).to match_array [included_school]
      end

      it "filters the list by induction tutor email" do
        create(:user, :induction_coordinator, email: "mary@schools.org", schools: [included_school])

        get "/admin/schools", params: { query: "mary" }
        expect(assigns(:schools)).to match_array [included_school]
      end
    end
  end

  describe "GET /admin/schools/:id" do
    let(:school) { create(:school) }

    context "the school is eligible" do
      it "renders the schools show template" do
        get "/admin/schools/#{school.id}"

        expect(response).to render_template("admin/schools/show")
        expect(response.body).to include(CGI.escapeHTML(school.name))
        expect(response.body).to include("Add induction tutor")
      end
    end

    context "the school is cip-only" do
      let(:school) { create(:school, :cip_only) }

      it "renders the schools show template" do
        get "/admin/schools/#{school.id}"

        expect(response).to render_template("admin/schools/show")
        expect(response.body).to include(CGI.escapeHTML(school.name))
        expect(response.body).to include("Add induction tutor")
      end
    end

    context "the school is closed" do
      let(:school) { create(:school, :closed) }

      it "raises a not found error (404)" do
        expect { get "/admin/schools/#{school.id}" }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when school is registered" do
      let!(:induction_coordinator) do
        create(:user, :induction_coordinator, schools: [school])
      end

      it "renders the induction coordinator's details" do
        get "/admin/schools/#{school.id}"

        expect(response.body).not_to include("Add induction tutor")
        expect(response.body).to include(CGI.escapeHTML(induction_coordinator.email))
        expect(response.body).to include(CGI.escapeHTML(induction_coordinator.full_name))
      end
    end
  end
end
