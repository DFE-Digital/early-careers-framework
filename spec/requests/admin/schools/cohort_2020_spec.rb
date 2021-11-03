# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohort2020", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:cip) { create(:core_induction_programme, name: "CIP Programme") }
  let(:cohort_2020) { create(:cohort, start_year: 2020) }
  let(:school_cohort) { create(:school_cohort, :cip, cohort: cohort_2020, school: school, core_induction_programme: cip) }
  let!(:participants) { create_list(:participant_profile, 5, :ect, school_cohort: school_cohort) }
  let(:other_cohort) { create(:cohort) }
  let(:other_school_cohort) { create(:school_cohort, :cip, cohort: other_cohort, school: school_cohort.school, core_induction_programme: cip) }
  let!(:other_participants) { create_list(:participant_profile, 5, :ect, school_cohort: other_school_cohort) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/cohort2020" do
    it "shows a list of 2020 participants" do
      get "/admin/schools/#{school_cohort.school.slug}/cohort2020"

      participants.each do |participant|
        expect(response.body).to include(CGI.escapeHTML(participant.user.full_name))
      end
    end

    it "does not include participants from other cohorts" do
      get "/admin/schools/#{school_cohort.school.slug}/cohort2020"

      other_participants.each do |participant|
        expect(response.body).not_to include(CGI.escapeHTML(participant.user.full_name))
      end
    end
  end

  describe "GET /admin/schools/:school_id/cohort2020/new" do
    it "renders the new template" do
      get "/admin/schools/#{school_cohort.school.slug}/cohort2020/new"

      expect(response).to render_template("admin/schools/cohort2020/new")
    end
  end

  describe "POST /admin/schools/:school_id/cohort2020" do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }

    it "creates a new NQT+1 participant" do
      expect(EarlyCareerTeachers::Create).to receive(:call).with({
        full_name: name,
        email: email,
        school_cohort: school_cohort,
        mentor_profile_id: nil,
        year_2020: true,
      })

      post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
        user: { full_name: name, email: email },
      }
    end
  end
end
