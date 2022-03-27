# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::AddParticipant", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school_cohort) { create(:school_cohort, :fip, school: school) }
  let(:school) { user.induction_coordinator_profile.schools.sample }
  let(:cohort) { create(:cohort, :current) }

  let!(:school_cohort) { create(:school_cohort, cohort: cohort, school: school) }
  subject { response }

  before do
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/add" do
    before do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add", params: { type: :joining }
    end

    it "sets up the form in the session" do
      expect(session[:schools_add_participant_form]).to include("school_cohort_id" => school_cohort.id)
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/add/who", with_feature_flags: { change_of_circumstances: "active" } do
    context "when session has not been set up with the form" do
      before do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/who"
      end

      it { is_expected.to redirect_to schools_cohort_path(school_id: school.slug, cohort_id: cohort.start_year) }
    end

    context "when form has been set up in the session" do
      before do
        set_session(:schools_add_participant_form, {
          type: :teacher,
          full_name: Faker::Name.name,
          email: Faker::Internet.email,
          mentor_id: "later",
          school_cohort_id: school_cohort.id,
          current_user_id: user.id,
          start_term: "Autumn 2050",
        })
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/who", params: { type: :joining }
      end

      it "renders the expected page" do
        expect(subject).to render_template(:who)
        expect(response.body).to include("A teacher transferring from another school")
        expect(response.body).to include("A new ECT")
      end
    end
  end

  Schools::AddParticipantForm.steps.keys.without(:email_taken).each do |step|
    describe "GET /schools/:school_id/cohort/:cohort_id/participants/add/#{step.to_s.dasherize}" do
      context "when session has not been set up with the form" do
        before do
          get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/#{step.to_s.dasherize}"
        end

        it { is_expected.to redirect_to schools_cohort_path(school.slug, cohort.start_year) }
      end

      context "when form has been set up in the session" do
        before do
          set_session(:schools_add_participant_form, {
            type: :ect,
            full_name: Faker::Name.name,
            email: Faker::Internet.email,
            mentor_id: "later",
            school_cohort_id: school_cohort.id,
            current_user_id: user.id,
            start_term: "Autumn 2050",
          })
          get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/#{step.to_s.dasherize}"
        end

        it { is_expected.to render_template step }
      end
    end
  end

  describe "GET /schools/cohort/:cohort_id/participants/add/email_taken" do
    context "when session has not been set up with the form" do
      before do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/email-taken"
      end

      it { is_expected.to redirect_to schools_cohort_path(school_id: school.slug, cohort_id: cohort.start_year) }
    end

    context "when form has been set up in the session" do
      let(:email) { Faker::Internet.email }
      let!(:other_user) { create :user, email: email }

      before do
        set_session(:schools_add_participant_form,
                    type: :ect,
                    full_name: Faker::Name.name,
                    email: email,
                    mentor_id: "later",
                    school_cohort_id: school_cohort.id,
                    current_user_id: user.id)
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/email-taken"
      end

      it { is_expected.to render_template :email_taken }
    end
  end
end
