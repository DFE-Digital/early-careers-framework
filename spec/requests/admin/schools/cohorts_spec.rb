# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:cip) { create(:core_induction_programme, name: "CIP Programme") }
  let(:school_cohort) { create(:school_cohort, school: school, core_induction_programme: cip) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/cohorts" do
    it "renders the index template" do
      get "/admin/schools/#{school.id}/cohorts"
      expect(response).to render_template("admin/schools/cohorts/index")
      expect(assigns(:school_cohorts)).to match_array school.school_cohorts
    end
  end
end
