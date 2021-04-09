# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Requesting an invitation to nominate an induction tutor", type: :request do
  let(:school) { create(:school) }
  before do
    create(:school_local_authority)
  end

  describe "choose location" do
    it "renders the choose location page" do
      get "/nominations/choose-location"
      expect(response).to render_template(:choose_location)
    end

    it "shows validation error" do
      post "/nominations/choose-location"
      expect(response).to render_template(:choose_location)
      expect(response.body).to include(CGI.escapeHTML("The details you entered do not match any establishments"))
    end

    it "redirects to choose-school" do
      post "/nominations/choose-location", params: { nomination_request_form: { local_authority_id: LocalAuthority.first.id } }
      expect(response).to redirect_to(choose_school_request_nomination_invite_path)
    end
  end

  describe "choose school" do
    it "renders the choose school page" do
      get "/nominations/choose-school"
      expect(response).to render_template(:choose_school)
    end

    it "shows validation error" do
      post "/nominations/choose-school"
      expect(response).to render_template(:choose_school)
      expect(response.body).to include(CGI.escapeHTML("The details you entered do not match any establishments"))
    end

    context "when given an eligible, un-nominated school" do
      it "redirects to review" do
        when_i_choose_the_school
        expect(response).to redirect_to(review_request_nomination_invite_path)
      end
    end

    context "when given an ineligible school" do
      let(:school) { create(:school, administrative_district_code: "W12") }

      it "redirects to not eligible" do
        when_i_choose_the_school
        expect(response).to redirect_to(not_eligible_request_nomination_invite_path)
      end
    end

    context "when given an eligible, already nominated school" do
      before do
        create(:user, :induction_coordinator, schools: [school])
      end

      it "redirects to already nominated" do
        when_i_choose_the_school
        expect(response).to redirect_to(already_nominated_request_nomination_invite_path)
      end
    end

    context "when given an eligible school emailed within the last 24 hours" do
      before do
        create(:nomination_email, school: school, sent_at: 1.hour.ago)
      end

      it "redirects to limit reached" do
        when_i_choose_the_school
        expect(response).to redirect_to(limit_reached_request_nomination_invite_path)
      end
    end
  end

  describe "review" do
    let(:session) { { nomination_request_form: { school_id: school.id } } }

    before do
      allow_any_instance_of(Nominations::RequestNominationInviteController)
        .to receive(:session)
              .and_return(session)
    end

    it "renders the review page" do
      get "/nominations/review"
      expect(response).to render_template(:review)
    end

    it "redirects to success page" do
      post "/nominations/review"
      expect(response).to redirect_to(success_request_nomination_invite_path)
    end
  end

  describe "success" do
    it "renders the success page" do
      get "/nominations/success"
      expect(response).to render_template(:success)
    end
  end

  describe "not eligible" do
    it "renders the not eligible page" do
      get "/nominations/not-eligible"
      expect(response).to render_template(:not_eligible)
    end
  end

  describe "email limit reached" do
    it "renders the email limit reached page" do
      get "/nominations/limit-reached"
      expect(response).to render_template(:limit_reached)
    end
  end

  describe "already nominated" do
    it "renders the already nominated page" do
      get "/nominations/already-nominated"
      expect(response).to render_template(:already_nominated)
    end
  end

private

  def when_i_choose_the_school
    post "/nominations/choose-school", params: { nomination_request_form: { school_id: school.id } }
  end
end
