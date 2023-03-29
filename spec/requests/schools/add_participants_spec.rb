# frozen_string_literal: true

require "rails_helper"

RSpec.xdescribe "Schools::AddParticipant", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let!(:school_cohort) { create(:school_cohort, :fip, school:, cohort:) }
  let(:school) { user.induction_coordinator_profile.schools.sample }
  let(:cohort) { create(:cohort, :current) }
  let(:appropriate_body) { create(:appropriate_body_national_organisation) }

  subject { response }

  before do
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/who" do
    before do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/who", params: { type: :ect }
    end

    it "sets up the form in the session" do
      expect(session[:add_participant_wizard]).to include(school_cohort_id: school_cohort.id)
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/who" do
    context "when form has been set up in the session" do
      before do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/who"
      end

      it "renders the expected page" do
        expect(subject).to render_template(:participant_type)
        expect(response.body).to include("This could be a new teacher or a teacher transferring from another school")
        expect(response.body).to include("ECT")
        expect(response.body).to include("Mentor")
      end
    end
  end

  # FIXME: something wrong with date handling in these specs
  Schools::AddParticipants::WhoToAddWizard.steps.without(:participant_type, :yourself, :cannot_find_their_details, :still_cannot_find_their_details).each do |step|
    describe "GET /schools/:school_id/cohort/:cohort_id/participants/who/#{step.to_s.dasherize}" do
      context "when session has not been set up with the form" do
        before do
          get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/who/#{step.to_s.dasherize}"
        end

        it { is_expected.to redirect_to schools_participants_path(school.slug, cohort.start_year) }
      end

      context "when form has been set up in the session" do
        before do
          set_session(:add_participant_wizard, {
            type: "ect",
            full_name: Faker::Name.name,
            email: Faker::Internet.email,
            # date_of_birth: Date.new(1990, 1, 1),
            mentor_id: "later",
            school_cohort_id: school_cohort.id,
            current_user: user,
          })
          get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/who/#{step.to_s.dasherize}"
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
      let!(:other_user) { create :user, email: }

      before do
        set_session(:add_participant_wizard,
                    type: :ect,
                    full_name: Faker::Name.name,
                    email:,
                    date_of_birth: Date.new(1990, 1, 1),
                    mentor_id: "later",
                    school_cohort_id: school_cohort.id,
                    current_user_id: user.id)
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/email-taken"
      end

      it { is_expected.to render_template :email_taken }
    end
  end

  describe "PUT /schools/cohort/:cohort_id/participants/add/transfer" do
    context "when form has been set up in the session" do
      let(:email) { Faker::Internet.email }
      let!(:other_user) { create :user, email: }

      context "when participant is a transfer" do
        let(:induction_programme) { create(:induction_programme, :fip, school_cohort: create(:school_cohort, cohort: participant_cohort)) }
        let(:ecf_participant_validation_data) { create(:ecf_participant_validation_data, trn: "3333333") }
        let(:teacher_profile) { create(:teacher_profile, trn: "3333333") }
        let(:participant_profile) { create(:ect_participant_profile, teacher_profile:, ecf_participant_validation_data:) }

        before do
          Induction::Enrol.call(participant_profile:, induction_programme:)
          participant_profile.participant_declarations
                             .create!(declaration_date: Date.new(participant_profile.cohort_start_year, 10, 10),
                                      declaration_type: :started,
                                      state: :paid,
                                      course_identifier: "ecf-induction",
                                      cpd_lead_provider: create(:cpd_lead_provider),
                                      user: participant_profile.user)

          set_session(:add_participant_wizard,
                      type: :ect,
                      full_name: Faker::Name.name,
                      email:,
                      trn: "3333333",
                      date_of_birth: Date.new(1990, 1, 1),
                      mentor_id: "later",
                      school_cohort_id: school_cohort.id,
                      current_user_id: user.id,
                      transfer: "true")
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/transfer", params: { step: :transfer }
        end

        context "when the target school cohort has not been set by the school yet" do
          let(:participant_cohort) { create(:cohort, start_year: cohort.start_year - 1) }

          it { is_expected.to render_template :target_school_cohort_not_set }
        end

        context "when the target school cohort has already been set by the school" do
          let(:participant_cohort) { cohort }

          it { is_expected.to redirect_to teacher_start_date_schools_transferring_participant_path }
        end
      end

      context "when participant is not a transfer" do
        before do
          set_session(:add_participant_wizard,
                      type: :ect,
                      full_name: Faker::Name.name,
                      email:,
                      date_of_birth: Date.new(1990, 1, 1),
                      mentor_id: "later",
                      school_cohort_id: school_cohort.id,
                      current_user_id: user.id,
                      transfer: "false")
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/add/transfer", params: { step: :transfer }
        end

        it { is_expected.to render_template :cannot_add }
      end
    end
  end
end
