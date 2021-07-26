# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::AddParticipant", type: :request do
  let!(:school) { create :school }
  let!(:cohort) { create :cohort, start_year: 2020 }
  let!(:core_induction_programme) { create :core_induction_programme }

  subject { response }

  before do
    FeatureFlag.activate(:year_2020_data_entry)
  end

  describe "GET /schools/:school_id/year-2020/start" do
    before do
      get "/schools/#{school.slug}/year-2020/start"
    end

    it { is_expected.to render_template("schools/year2020/start") }
  end

  describe "GET /schools/:school_id/year-2020/choose-induction-programme" do
    before do
      get "/schools/#{school.slug}/year-2020/choose-induction-programme"
    end

    it { is_expected.to render_template("schools/year2020/select_induction_programme") }
  end

  describe "PUT /schools/:school_id/year-2020/choose-induction-programme" do
    it "renders the select_induction_programme if programme choice is missing" do
      put "/schools/#{school.slug}/year-2020/choose-induction-programme"
      expect(response).to render_template("schools/year2020/select_induction_programme")
    end

    it "redirects to cip choice page when programme choice is CIP" do
      put "/schools/#{school.slug}/year-2020/choose-induction-programme", params: {
        schools_year2020_form: { induction_programme_choice: "core_induction_programme" },
      }
      expect(response).to redirect_to "/schools/#{school.slug}/year-2020/choose-core-induction-programme"
    end

    it "redirects to no programme page when school opts out" do
      put "/schools/#{school.slug}/year-2020/choose-induction-programme", params: {
        schools_year2020_form: { induction_programme_choice: "no_programme" },
      }
      expect(response).to redirect_to "/schools/#{school.slug}/year-2020/no-accredited-materials"
    end
  end

  describe "GET /schools/:school_id/year-2020/no-accredited-materials" do
    before do
      get "/schools/#{school.slug}/year-2020/no-accredited-materials"
    end

    it { is_expected.to render_template("schools/year2020/no_accredited_materials") }
  end

  describe "GET /schools/:school_id/year-2020/choose-core-induction-programme" do
    before do
      get "/schools/#{school.slug}/year-2020/choose-core-induction-programme"
    end

    it { is_expected.to render_template("schools/year2020/select_cip") }
  end

  describe "PUT /schools/:school_id/year-2020/choose-core-induction-programme" do
    it "renders the select_induction_programme if cip choice is missing" do
      put "/schools/#{school.slug}/year-2020/choose-core-induction-programme"
      expect(response).to render_template("schools/year2020/select_cip")
    end

    it "redirects to new teacher page when programme choice is valid" do
      put "/schools/#{school.slug}/year-2020/choose-core-induction-programme", params: {
        schools_year2020_form: { core_induction_programme_id: core_induction_programme.id },
      }
      expect(response).to redirect_to "/schools/#{school.slug}/year-2020/add-teacher"
    end
  end

  describe "GET /schools/:school_id/year-2020/add-teacher" do
    before do
      get "/schools/#{school.slug}/year-2020/add-teacher"
    end

    it { is_expected.to render_template("schools/year2020/new_teacher") }
  end

  describe "PUT /schools/:school_id/year-2020/add-teacher" do
    it "renders the select_induction_programme if teacher details are missing" do
      put "/schools/#{school.slug}/year-2020/add-teacher"
      expect(response).to render_template("schools/year2020/new_teacher")
    end

    it "redirects to check page when teacher details are valid" do
      put "/schools/#{school.slug}/year-2020/add-teacher", params: {
        schools_year2020_form: { full_name: "Joe Bloggs", email: "joe@example.com" },
      }
      expect(response).to redirect_to "/schools/#{school.slug}/year-2020/check-your-answers"
    end
  end

  describe "GET /schools/:school_id/year-2020/check-your-answers" do
    before do
      get "/schools/#{school.slug}/year-2020/check-your-answers"
    end

    it { is_expected.to render_template("schools/year2020/check") }
  end

  describe "POST /schools/:school_id/year-2020/check-your-answers" do
    before do
      set_session(:schools_year2020_form,
                  full_name: "Joe Bloggs",
                  email: "joe@example.com",
                  school_id: school.friendly_id,
                  induction_programme_choice: "core_induction_programme",
                  core_induction_programme_id: core_induction_programme.id)
    end

    it "redirects to success page" do
      post "/schools/#{school.slug}/year-2020/check-your-answers"
      expect(response).to redirect_to "/schools/#{school.slug}/year-2020/success"
    end

    it "saves the data" do
      post "/schools/#{school.slug}/year-2020/check-your-answers"
      school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)

      expect(school_cohort).not_to be_nil
      expect(school_cohort.ecf_participants.count).to eq(1)
      expect(school_cohort.ecf_participants.first.full_name).to eq("Joe Bloggs")
      expect(school_cohort.ecf_participants.first.email).to eq("joe@example.com")
    end
  end

  describe "GET /schools/:school_id/year-2020/success" do
    before do
      get "/schools/#{school.slug}/year-2020/success"
    end

    it { is_expected.to render_template("schools/year2020/success") }
  end
end
