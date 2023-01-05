# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohort2020", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:cip) { create(:core_induction_programme, name: "CIP Programme") }
  let(:cohort_2020) { Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020) }
  let(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, :cip, cohort: cohort_2020, school:, core_induction_programme: cip) }
  let(:current_cohort) { Cohort.current || create(:cohort, :current) }
  let(:other_school_cohort) { create(:school_cohort, :cip, cohort: current_cohort, school: school_cohort.school, core_induction_programme: cip) }

  let!(:schedule) { create(:ecf_schedule, cohort: cohort_2021) }
  let!(:participants) { create_list(:ect_participant_profile, 5, school_cohort:) }
  let!(:other_participants) { create_list(:ect_participant_profile, 5, school_cohort: other_school_cohort) }

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
        email:,
        school_cohort:,
        mentor_profile_id: nil,
        year_2020: true,
      })

      post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
        user: { full_name: name, email: },
      }
    end

    context "when there is an active ECT with that email" do
      let!(:participant_profile) { create(:ect_participant_profile, school_cohort: build(:school_cohort, cohort: current_cohort)) }
      let(:name) { participant_profile.user.full_name }
      let(:email) { participant_profile.user.email }

      it "shows an error message" do
        expect(EarlyCareerTeachers::Create).not_to receive(:call)

        post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
          user: { full_name: name, email: },
        }

        expect(response).to render_template("admin/schools/cohort2020/new")
        expect(response.body).to include("A user with this email address is currently participating as an ECT")
      end
    end

    context "when there is an inactive ECT with that email" do
      let!(:participant_profile) { create(:ect_participant_profile, :withdrawn_record) }
      let(:name) { participant_profile.user.full_name }
      let(:email) { participant_profile.user.email }

      it "adds an NQT+1 profile to the user" do
        expect {
          post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
            user: { full_name: name, email: },
          }
        }.to raise_error EarlyCareerTeachers::Create::ParticipantProfileExistsError
      end
    end

    context "when there is an active mentor with that email" do
      let!(:participant_profile) { create(:mentor_participant_profile) }
      let(:name) { participant_profile.user.full_name }
      let(:email) { participant_profile.user.email }

      it "adds an NQT+1 profile to the user" do
        expect(EarlyCareerTeachers::Create).to receive(:call).with({
          full_name: name,
          email:,
          school_cohort:,
          mentor_profile_id: nil,
          year_2020: true,
        }).and_call_original

        post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
          user: { full_name: name, email: },
        }

        expect(User.find_by(email:).participant_profiles.count).to eql 2
      end

      it "does not change the name on the user" do
        original_name = name
        other_name = "Other name"

        expect(EarlyCareerTeachers::Create).to receive(:call).with({
          full_name: other_name,
          email:,
          school_cohort:,
          mentor_profile_id: nil,
          year_2020: true,
        }).and_call_original

        post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
          user: { full_name: other_name, email: },
        }

        expect(User.find_by(email:).full_name).to eql original_name
      end
    end

    context "when there is an npq participant with that email", :with_default_schedules do
      let!(:participant_profile) { create(:npq_participant_profile) }
      let(:name) { participant_profile.user.full_name }
      let(:email) { participant_profile.user.email }

      it "adds an NQT+1 profile to the user" do
        expect(EarlyCareerTeachers::Create).to receive(:call).with({
          full_name: name,
          email:,
          school_cohort:,
          mentor_profile_id: nil,
          year_2020: true,
        }).and_call_original

        post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
          user: { full_name: name, email: },
        }

        expect(User.find_by(email:).participant_profiles.count).to eql 2
      end

      it "does not change the name on the user" do
        original_name = name
        other_name = "Other name"

        expect(EarlyCareerTeachers::Create).to receive(:call).with({
          full_name: other_name,
          email:,
          school_cohort:,
          mentor_profile_id: nil,
          year_2020: true,
        }).and_call_original

        post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
          user: { full_name: other_name, email: },
        }

        expect(User.find_by(email:).full_name).to eql original_name
      end
    end

    context "when there is an NQT+1 with that email" do
      let!(:participant_profile) { create(:ect_participant_profile, school_cohort: build(:school_cohort, cohort: cohort_2020)) }
      let(:name) { participant_profile.user.full_name }
      let(:email) { participant_profile.user.email }

      it "shows an error message" do
        expect(EarlyCareerTeachers::Create).not_to receive(:call)

        post "/admin/schools/#{school_cohort.school.slug}/cohort2020", params: {
          user: { full_name: name, email: },
        }

        expect(response).to render_template("admin/schools/cohort2020/new")
        expect(response.body).to include("A user with this email address is currently participating as an NQT+1")
      end
    end
  end
end
