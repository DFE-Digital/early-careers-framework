# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nominating an induction coordinator", type: :request do
  describe "GET /nominations/start" do
    it "redirects to choose how to continue" do
      get "/nominations/start"
      expect(response).to redirect_to("/nominations/choose-how-to-continue")
    end
  end

  describe "GET /nominations/start-nomination" do
    it "redirects to link-invalid when no token is provided" do
      get "/nominations/start-nomination"
      expect(response).to redirect_to("/nominations/link-invalid")
    end

    it "redirects to link-invalid when an invalid token is provided" do
      get "/nominations/start-nomination?token=abc123"
      expect(response).to redirect_to("/nominations/link-invalid")
    end

    context "with a valid token" do
      let(:school) { create :school }
      let(:access_token) { create :school_access_token, school: school, permitted_actions: %i[nominate_tutor] }
      let(:token) { access_token.token }

      it "renders the start nomination template" do
        get "/nominations/start-nomination?token=#{token}"

        expect(response).to render_template("nominations/nominate_induction_coordinator/start_nomination")
      end

      context "when an induction tutor for the school has already been nominated" do
        before do
          create(:user, :induction_coordinator, schools: [school])
        end

        it "redirects to already-nominated" do
          get "/nominations/start-nomination?token=#{token}"

          expect(response).to redirect_to("/nominations/already-nominated")
          follow_redirect!
          expect(response).to render_template("nominations/request_nomination_invite/already_nominated")
        end
      end
    end

    context "with an expired token" do
      let(:access_token) { create(:school_access_token, :expired) }
      let(:token) { access_token.token }

      it "redirects to link-expired" do
        get "/nominations/start-nomination?token=#{token}"

        expect(response).to redirect_to("/nominations/link-expired?school_id=#{access_token.school.id}")
      end
    end

    context "with a nearly expired token" do
      let(:access_token) { create(:school_access_token, :nearly_expired, permitted_actions: %i[nominate_tutor]) }
      let(:token) { access_token.token }

      it "renders the start nomination template" do
        get "/nominations/start-nomination?token=#{token}"

        expect(response).to render_template("nominations/nominate_induction_coordinator/start_nomination")
      end
    end
  end

  context "user has started sit nomination" do
    let!(:school_access_token) { create(:school_access_token, school: school, permitted_actions: %i[nominate_tutor]) }
    let!(:school) { create :school }
    let!(:name) { Faker::Name.name }
    let!(:email) { Faker::Internet.email }

    describe "GET /nominations/full-name" do
      before do
        get "/nominations/start-nomination?token=#{school_access_token.token}"
      end

      it "renders the full-name template" do
        get "/nominations/full-name"
        expect(response).to render_template("nominations/nominate_induction_coordinator/full_name")
      end
    end

    describe "PUT /nominations/full-name" do
      before do
        get "/nominations/start-nomination?token=#{school_access_token.token}"
      end

      it "redirects to the email template when a valid name is inputted" do
        put "/nominations/full-name", params: { nominate_induction_tutor_form: {
          full_name: name,
          email: "",
        } }

        expect(response).to redirect_to("/nominations/email")
      end

      it "shows a validation error when the name is blank" do
        put "/nominations/full-name", params: { nominate_induction_tutor_form: {
          full_name: "",
          email: "",
        } }

        expect(response).to render_template("nominations/nominate_induction_coordinator/full_name")
        expect(response.body).to include(CGI.escapeHTML("Enter a full name"))
      end
    end

    describe "GET /nominations/email" do
      before do
        get "/nominations/start-nomination?token=#{school_access_token.token}"
      end

      it "renders the email template" do
        get "/nominations/email", params: { nominate_induction_tutor_form: {
          full_name: name,
          email: "",
        } }

        expect(response).to render_template("nominations/nominate_induction_coordinator/email")
      end
    end

    describe "PUT /nominations/email" do
      before do
        get "/nominations/start-nomination?token=#{school_access_token.token}"
      end

      it "redirects to the check template when a valid email is inputted" do
        put "/nominations/email", params: { nominate_induction_tutor_form: {
          full_name: name,
          email: email,
        } }

        expect(response).to redirect_to("/nominations/check-details")
      end

      it "shows a validation error when the email is blank" do
        put "/nominations/email", params: { nominate_induction_tutor_form: {
          full_name: name,
          email: "",
        } }

        expect(response).to render_template("nominations/nominate_induction_coordinator/email")
        expect(response.body).to include(CGI.escapeHTML("Enter an email"))
      end

      it "shows a validation error when the email is invalid" do
        put "/nominations/email", params: { nominate_induction_tutor_form: {
          full_name: name,
          email: "invalid@email",
        } }

        expect(response).to render_template("nominations/nominate_induction_coordinator/email")
        expect(response.body).to include(CGI.escapeHTML("Enter an email address in the correct format, like name@example.com"))
      end

      context "when an induction coordinator already exists with the provided email" do
        let!(:existing_induction_coordinator) { create(:user, :induction_coordinator, email: email) }

        it "redirects to the name-different page when the form name does not match our records" do
          expect {
            put "/nominations/email", params: { nominate_induction_tutor_form: {
              full_name: "Different Name",
              email: email,
            } }
          }.not_to(change { User.count })

          expect(existing_induction_coordinator.schools.count).to eql 1
          expect(existing_induction_coordinator.schools).not_to include school
          expect(response).to redirect_to("/nominations/name-different")
        end
      end

      context "when an ECT user already exists with the provided email" do
        let!(:existing_user) { create(:ect_participant_profile, user: create(:user, email: email)).user }

        it "redirects to the email-used page" do
          expect {
            put "/nominations/email", params: { nominate_induction_tutor_form: {
              full_name: name,
              email: email,
            } }
          }.not_to(change { User.count })

          expect(response).to redirect_to("/nominations/email-used")
        end
      end
    end

    describe "GET /nominations/check-details" do
      before do
        get "/nominations/start-nomination?token=#{school_access_token.token}"
      end

      it "renders the check template" do
        get "/nominations/check-details", params: { nominate_induction_tutor_form: {
          full_name: name,
          email: email,
        } }
        expect(response).to render_template("nominations/nominate_induction_coordinator/check")
      end
    end

    describe "POST /nominations/check-details" do
      before do
        get "/nominations/start-nomination?token=#{school_access_token.token}"
      end

      it "creates a user and induction coordinator profile with the given details" do
        expect {
          post "/nominations/check-details", params: { nominate_induction_tutor_form: {
            full_name: name,
            email: email,
          } }
        }
          .to change { User.count }.by(1)
          .and change { InductionCoordinatorProfile.count }.by(1)

        created_user = User.find_by(email: email)
        expect(created_user).not_to be_nil
        expect(created_user.full_name).to eql name
        expect(created_user.induction_coordinator_profile.schools).to contain_exactly(school)
        expect(response).to redirect_to("/nominations/nominate-school-lead-success")
      end

      context "when an induction coordinator already exists with the provided email" do
        let!(:existing_induction_coordinator) { create(:user, :induction_coordinator, email: email) }

        it "adds the schools to their list of schools" do
          expect {
            post "/nominations/check-details", params: { nominate_induction_tutor_form: {
              full_name: existing_induction_coordinator.full_name,
              email: email,
            } }
          }.not_to(change { User.count })

          expect(existing_induction_coordinator.schools.count).to eql 2
          expect(existing_induction_coordinator.schools).to include school
          expect(response).to redirect_to("/nominations/nominate-school-lead-success")
        end
      end
    end
  end

  describe "GET /nominations/link-expired" do
    let(:school) { create(:school) }

    it "renders the link-expired template" do
      get "/nominations/link-expired?school=#{school.id}"

      expect(response).to render_template("nominations/nominate_induction_coordinator/link_expired")
    end
  end

  describe "POST /nominations/link-expired" do
    let(:school) { create(:school, :with_local_authority) }

    it "calls save! on the form" do
      expect_any_instance_of(NominationRequestForm).to receive(:save!)
      post "/nominations/link-expired", params: { resend_email_after_link_expired: {
        school_id: school.id,
      } }
    end

    it "redirects to limit-reached" do
      expect_any_instance_of(NominationRequestForm).to receive(:save!).and_raise(TooManyEmailsError)

      post "/nominations/link-expired", params: { resend_email_after_link_expired: {
        school_id: school.id,
      } }
      expect(response).to redirect_to(limit_reached_request_nomination_invite_path)
    end
  end

  describe "GET /nominations/email-used" do
    it "renders the email used template" do
      get "/nominations/email-used"
      expect(response).to render_template("nominations/nominate_induction_coordinator/email_used")
    end
  end

  describe "GET /nominations/nominate-school-lead-success" do
    it "renders the success template" do
      get "/nominations/nominate-school-lead-success"
      expect(response).to render_template("nominations/nominate_induction_coordinator/nominate_school_lead_success")
    end
  end
end
