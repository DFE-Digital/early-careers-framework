# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::UserProfile", type: :request do
  let(:school) { create(:school) }
  let(:full_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:session) { { school_urn: school.urn } }
  let(:created_user) { User.find_by_email(email) }

  before do
    allow_any_instance_of(Registrations::UserProfileController)
      .to receive(:session)
      .and_return(session)
  end

  describe "GET /registrations/user-profile/new" do
    it "renders the show template" do
      get "/registrations/user-profile/new"
      expect(response).to render_template("registrations/user_profile/new")
    end
  end

  describe "POST /registrations/user-profile" do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
      allow(UserMailer).to receive(:confirmation_instructions).and_return(mail)
    end

    context "when request is valid" do
      let(:send_request) do
        post "/registrations/user-profile", params: { user: {
          full_name: full_name,
          email: email,
        } }
      end

      it "creates an induction coordinator profile" do
        send_request
        expect(created_user.full_name).to eq(full_name)
        expect(created_user.induction_coordinator_profile.schools).to include(school)
      end

      it "redirects to verification sent page" do
        send_request
        expect(response).to redirect_to(:registrations_verification_sent)
      end

      it "sends a confirmation email" do
        send_request
        expect(UserMailer).to have_received(:confirmation_instructions).with(created_user, /.*/, {})
      end

      context "when school has old unconfirmed registrations" do
        let(:user) { create(:user, confirmed_at: nil) }
        let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

        before do
          user.update!(confirmation_sent_at: 2.days.ago)
        end

        it "registers new induction coordinator" do
          send_request
          expect(school.reload.induction_coordinator_profiles).to include created_user.induction_coordinator_profile
        end

        it "removes the old coordinator profiles" do
          send_request
          expect(school.induction_coordinator_profiles).not_to include user.reload.induction_coordinator_profile
        end

        it "sends a confirmation email to the new induction coordinator" do
          send_request
          expect(UserMailer).to have_received(:confirmation_instructions).with(created_user, /.*/, {})
        end
      end
    end

    context "when email is missing" do
      let(:send_request) do
        post "/registrations/user-profile", params: { user: {
          full_name: full_name,
        } }
      end

      it "does not create the user" do
        expect { send_request }.not_to(change { User.count })
      end

      it "shows validation error" do
        send_request
        expect(response.body).to include("Enter an email")
        expect(response).to render_template("registrations/user_profile/new")
      end

      it "does not send a confirmation email" do
        send_request
        expect(UserMailer).not_to have_received(:confirmation_instructions)
      end
    end

    context "when full name is missing" do
      let(:send_request) do
        post "/registrations/user-profile", params: { user: {
          email: email,
        } }
      end

      it "does not create the user" do
        expect { send_request }.not_to(change { User.count })
      end

      it "shows validation error" do
        send_request
        expect(response.body).to include("Enter a full name")
        expect(response).to render_template("registrations/user_profile/new")
      end

      it "does not send a confirmation email" do
        send_request
        expect(UserMailer).not_to have_received(:confirmation_instructions)
      end
    end

    context "when the school urn is missing" do
      before do
        allow_any_instance_of(Registrations::UserProfileController)
          .to receive(:session)
          .and_return({})
      end

      it "returns a bad request error" do
        expect {
          post "/registrations/user-profile", params: { user: {
            full_name: full_name,
            email: email,
          } }
        }.to raise_error(ActionController::BadRequest)
        expect(UserMailer).not_to have_received(:confirmation_instructions)
      end
    end
  end
end
