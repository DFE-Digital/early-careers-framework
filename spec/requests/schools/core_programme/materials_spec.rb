# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::CoreProgramme::Materials", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let!(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:default_induction_programme) { create(:induction_programme, :cip) }
  let!(:school_cohort) { create :school_cohort, school:, cohort:, induction_programme_choice: "core_induction_programme", default_induction_programme: }
  let(:cip) { create :core_induction_programme }

  before do
    sign_in user
  end

  describe "GET /schools/cohorts/:id/core-programme/materials/info" do
    context "when cohort has no materials selected yet" do
      it "renders the materials info template" do
        get "/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials/info"

        expect(response).to render_template("schools/core_programme/materials/info")
      end
    end

    context "when cohort already has selected materials" do
      before do
        school_cohort.update(core_induction_programme: cip)
      end

      it "redirects to the materials page" do
        get "/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials/info"

        expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials")
      end
    end
  end

  describe "GET /schools/cohorts/:id/core-programme/materials/edit" do
    context "when cohort has no materials selected yet" do
      it "renders the materials edit template" do
        get "/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials/edit"

        expect(response).to render_template("schools/core_programme/materials/edit")
      end
    end
    context "when cohort already has selected materials" do
      before do
        school_cohort.update(core_induction_programme: cip)
      end

      it "redirects to the materials page" do
        get "/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials/edit"

        expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials")
      end
    end
  end

  describe "PUT /schools/cohorts/:id/core-programme/materials" do
    def update!
      put(
        "/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials",
        params: {
          core_induction_programme_choice_form: {
            core_induction_programme_id: cip.id,
          },
        },
      )
    end

    context "when cohort has no materials selected yet" do
      it "stores material selection within school cohort model" do
        update!
        expect(school_cohort.reload.core_induction_programme_id).to eq cip.id
      end

      it "redirects to success page" do
        update!
        expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials/success")
      end
    end

    context "when cohort already has selected materials" do
      let(:selected_cip) { create :core_induction_programme }

      before do
        school_cohort.update(core_induction_programme: selected_cip)
      end

      it "doesn't affect model" do
        update!
        expect(school_cohort.reload.core_induction_programme_id).to eq selected_cip.id
      end

      it "redirects to the materials page" do
        update!
        expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials")
      end
    end
  end

  describe "GET /schools/:school_id/cohorts/:id/core-programme/materials/success" do
    it "renders the materials success template" do
      get "/schools/#{school.slug}/cohorts/#{Cohort.current.start_year}/core-programme/materials/success"

      expect(response).to render_template("schools/core_programme/materials/success")
    end
  end
end
