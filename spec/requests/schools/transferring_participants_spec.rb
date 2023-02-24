# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::TransferringParticipants", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.sample }
  let(:old_school) { create(:school) }
  let(:cohort) { create(:cohort, :current) }
  let!(:school_cohort) { create(:school_cohort, cohort:, school:, induction_programme_choice: "full_induction_programme") }
  let(:old_school_cohort) { create(:school_cohort, cohort:, school: old_school, induction_programme_choice: "full_induction_programme") }
  let!(:delivery_partner) { create(:delivery_partner, name: "Amazing delivery partner") }
  let!(:lead_provider) { create(:lead_provider, name: "Big Provider Ltd") }
  let(:ect) { create(:ect_participant_profile, school_cohort:, user: create(:user, full_name: "Darryn Binder")) }
  let!(:ecf_participant_validation_data) { create(:ecf_participant_validation_data, full_name: ect.user.full_name, trn: "1001000", date_of_birth: Date.new(1990, 10, 24), participant_profile: ect) }
  let!(:school_cohort) { create(:school_cohort, cohort:, school:) }
  let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }
  let!(:old_partnership) { create(:partnership, school: old_school, cohort:, delivery_partner:, lead_provider:) }
  let(:induction_programme_one) { create(:induction_programme, :fip, school_cohort:, partnership:) }
  let(:induction_programme_two) { create(:induction_programme, :fip, school_cohort: old_school_cohort, partnership: old_partnership) }
  let!(:induction_record) { Induction::Enrol.call(participant_profile: ect, induction_programme: induction_programme_two) }
  # let!(:current_induction_programme) { create(:induction_programme, :fip, school_cohort: old_school_cohort) }

  subject { response }

  before do
    school_cohort.update!(default_induction_programme: induction_programme_one)
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant" do
    it "renders the what we need template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/what-we-need"

      expect(subject).to render_template "schools/transferring_participants/what_we_need"
      expect(response.body).to include("What we need from you")
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/full-name" do
    it "renders the full_name template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/full-name"

      expect(subject).to render_template "schools/transferring_participants/full_name"
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/full-name" do
    it "redirects to the trn template" do
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/full-name", params: { schools_transferring_participant_form: { full_name: ect.user.full_name } }

      expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/trn"
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/trn" do
    it "renders the trn template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/trn", params: { schools_transferring_participant_form: { full_name: ect.user.full_name } }

      expect(subject).to render_template "schools/transferring_participants/trn"
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/trn" do
    it "redirects to the date of birth template" do
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/trn",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
          } }

      expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/dob"
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/dob" do
    it "renders the dob template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/dob",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
          } }

      expect(subject).to render_template "schools/transferring_participants/dob"
    end
  end

  context "Enough details have been provided to check against DQT" do
    before do
      response = {
        trn: ecf_participant_validation_data.trn,
        full_name: ecf_participant_validation_data.full_name,
        nino: nil,
        dob: ecf_participant_validation_data.date_of_birth,
        config: {},
      }
      expect_any_instance_of(ParticipantValidationService).to receive(:validate).and_return(response)
    end

    describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/full-name" do
      context "user has provided exact name as in dqt" do
        it "redirects to the teacher start date template" do
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/full-name",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teacher-start-date"
        end
      end

      context "user has provided correct first name" do
        it "redirects to the teacher start date template" do
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/full-name",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name.split(" ").first,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teacher-start-date"
        end
      end
    end

    describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/trn" do
      it "redirects to the teacher start date template" do
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/trn",
            params: { schools_transferring_participant_form: {
              full_name: ect.user.full_name,
              trn: ecf_participant_validation_data.trn,
              date_of_birth: ecf_participant_validation_data.date_of_birth,
            } }

        expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teacher-start-date"
      end
    end

    describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/dob" do
      it "redirects to the teacher start date template" do
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/dob",
            params: { schools_transferring_participant_form: {
              full_name: ect.user.full_name,
              trn: ecf_participant_validation_data.trn,
              date_of_birth: ecf_participant_validation_data.date_of_birth,
            } }

        expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teacher-start-date"
      end
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/teacher-start-date" do
    it "renders the teacher start date template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teacher-start-date",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
            date_of_birth: ecf_participant_validation_data.date_of_birth,
          } }

      expect(subject).to render_template "schools/transferring_participants/teacher_start_date"
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/teacher-start-date" do
    it "redirects to the email template" do
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teacher-start-date",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
            date_of_birth: ecf_participant_validation_data.date_of_birth,
            start_date: Date.new(2022, 10, 20),
          } }

      expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/email"
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/email" do
    it "renders the email template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/email",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
            date_of_birth: ecf_participant_validation_data.date_of_birth,
          } }

      expect(subject).to render_template "schools/transferring_participants/email"
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/email" do
    it "redirects to the choose mentor template" do
      mentor = create(:mentor_participant_profile, school_cohort:)
      Induction::Enrol.call(participant_profile: mentor, induction_programme: induction_programme_one)
      school.school_mentors.create!(participant_profile: mentor, preferred_identity: mentor.participant_identity)
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/email",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
            date_of_birth: ecf_participant_validation_data.date_of_birth,
            email: Faker::Internet.email,
          } }

      expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/choose-mentor"
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/choose-mentor" do
    it "renders the choose-mentor template" do
      mentor = create(:mentor_participant_profile, school_cohort:)
      Induction::Enrol.call(participant_profile: mentor, induction_programme: induction_programme_one)
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/choose-mentor",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
            date_of_birth: ecf_participant_validation_data.date_of_birth,
          } }

      expect(subject).to render_template "schools/transferring_participants/choose_mentor"
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/choose-mentor" do
    context "teacher is with matching lead provider and delivery partner" do
      it "redirects to the check answers template" do
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/choose-mentor",
            params: { schools_transferring_participant_form: {
              full_name: ect.user.full_name,
              trn: ecf_participant_validation_data.trn,
              date_of_birth: ecf_participant_validation_data.date_of_birth,
              mentor_id: "later",
            } }
        expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/check-answers"
      end
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/choose-mentor" do
    context "teachers provider is not the same as new school" do
      it "redirects to the schools current programme template" do
        old_partnership.update!(delivery_partner: create(:delivery_partner), lead_provider: create(:lead_provider))

        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/choose-mentor",
            params: { schools_transferring_participant_form: {
              full_name: ect.user.full_name,
              trn: ecf_participant_validation_data.trn,
              date_of_birth: ecf_participant_validation_data.date_of_birth,
              mentor_id: "later",
            } }

        expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teachers-current-programme"
      end
    end
  end

  describe "GET /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/schools-current-programme" do
    it "renders the schools current programme template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/schools-current-programme",
          params: { schools_transferring_participant_form: {
            full_name: ect.user.full_name,
            trn: ecf_participant_validation_data.trn,
            date_of_birth: ecf_participant_validation_data.date_of_birth,
          } }

      expect(subject).to render_template "schools/transferring_participants/schools_current_programme"
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/schools-current-programme" do
    context "teacher is with the same lead provider and delivery partner as new school" do
      context "SIT selects for teacher to do same programme as school" do
        it "redirects to the check answers template" do
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/schools-current-programme",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
                schools_current_programme_choice: "yes",
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/check-answers"
        end
      end

      context "SIT selects for them not to do the same as the school" do
        it "redirects to the cannot add template" do
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/schools-current-programme",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
                schools_current_programme_choice: "no",
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/cannot-add"
        end
      end
    end

    context "teacher is with the same lead provider as new school but different delivery partner" do
      context "SIT selects for teacher to use the same delivery partner as the school" do
        it "redirects to the check answers template" do
          old_partnership.update!(delivery_partner: create(:delivery_partner))

          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/schools-current-programme",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
                schools_current_programme_choice: "yes",
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/check-answers"
        end
      end
    end
  end

  describe "PUT /schools/:school_id/cohorts/:cohort_id/participants/transferring-participant/teachers-current-programme" do
    context "teacher is with the different lead provider and delivery partner" do
      context "SIT selects for teacher not to continue with existing programme" do
        it "redirects to the schools current programme template" do
          induction_record.update!(induction_programme: create(:induction_programme, :fip, school_cohort: old_school_cohort))

          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/teachers-current-programme",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
                teachers_current_programme_choice: "no",
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/schools-current-programme"
        end
      end
    end

    context "SIT has already selected for teacher not to continue with their programme" do
      context "SIT selects for them not to do the same as the school" do
        it "redirects to the cannot add template" do
          induction_record.update!(induction_programme: create(:induction_programme, :fip, school_cohort: old_school_cohort))
          put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/schools-current-programme",
              params: { schools_transferring_participant_form: {
                full_name: ect.user.full_name,
                trn: ecf_participant_validation_data.trn,
                date_of_birth: ecf_participant_validation_data.date_of_birth,
                schools_current_programme_choice: "no",
                teachers_current_programme_choice: "no",
              } }

          expect(subject).to redirect_to "/schools/#{school.slug}/cohorts/#{cohort.start_year}/transferring-participant/cannot-add"
        end
      end
    end
  end
end
