# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "redirects to start nomination" do |how_to_continue|
  let(:form_params) do
    { nominate_how_to_continue_form: { how_to_continue: how_to_continue, token: token } }
  end

  it "redirects to the start of the nominate journey" do
    post "/nominations/choose-how-to-continue", params: form_params
    expect(response).to redirect_to "/nominations/start-nomination?token=#{token}"
  end

  context "when a school cohort already exists" do
    before do
      create(:school_cohort, school: school, cohort: cohort, opt_out_of_updates: true)
    end

    it "resets the opt out choice" do
      post "/nominations/choose-how-to-continue", params: form_params
      expect(school.school_cohorts.for_year(cohort.start_year).first).not_to be_opt_out_of_updates
    end
  end
end

RSpec.describe "Choosing how to continue with nominations", type: :request do
  let(:cohort) { create(:cohort, :current) }

  before do
    cohort
  end

  describe "GET /nominations/start" do
    it "redirects to /nominations/choose-how-to-continue" do
      get "/nominations/start"
      expect(response).to redirect_to("/nominations/choose-how-to-continue")
    end
  end

  describe "GET /nominations/choose-how-to-continue" do
    it "redirects to link-invalid when no token is provided" do
      get "/nominations/choose-how-to-continue"
      expect(response).to redirect_to("/nominations/link-invalid")
    end

    it "redirects to link-invalid when an invalid token is provided" do
      get "/nominations/choose-how-to-continue?token=abc123"
      expect(response).to redirect_to("/nominations/link-invalid")
    end

    context "with a valid token" do
      let(:nomination_email) { create(:nomination_email) }
      let(:token) { nomination_email.token }

      it "renders the nomination choices template" do
        get "/nominations/choose-how-to-continue?token=#{token}"

        expect(response).to render_template("nominations/choose_how_to_continue/new")
      end

      context "when an induction tutor for the school has already been nominated" do
        before do
          school = nomination_email.school
          create(:user, :induction_coordinator, schools: [school])
        end

        it "redirects to already-nominated" do
          get "/nominations/choose-how-to-continue?token=#{token}"

          expect(response).to redirect_to("/nominations/already-nominated")
          follow_redirect!
          expect(response).to render_template("nominations/request_nomination_invite/already_nominated")
        end
      end
    end

    context "with an expired token" do
      let(:nomination_email) { create(:nomination_email, :expired_nomination_email) }
      let(:token) { nomination_email.token }

      it "redirects to link-expired" do
        get "/nominations/choose-how-to-continue?token=#{token}"

        expect(response).to redirect_to("/nominations/link-expired?school_id=#{nomination_email.school.id}")
      end
    end

    context "with a nearly expired token" do
      let(:nomination_email) { create(:nomination_email, :nearly_expired_nomination_email) }
      let(:token) { nomination_email.token }

      it "renders the start nomination template" do
        get "/nominations/choose-how-to-continue?token=#{token}"

        expect(response).to render_template("nominations/choose_how_to_continue/new")
      end
    end
  end

  describe "POST /nominations/choose-how-to-continue" do
    let(:nomination_email) { create(:nomination_email) }
    let(:token) { nomination_email.token }
    let(:school) { nomination_email.school }

    context "recording the opened_at for the nomaination email" do
      let(:form_params) do
        { nominate_how_to_continue_form: { how_to_continue: "no", token: token } }
      end

      context "when making a choice for the first time" do
        let(:nomination_email) { create :nomination_email, opened_at: nil }
        let(:now) { rand(-100..100).hours.ago }

        it "records opened_at on the nomination_email" do
          travel_to now do
            post "/nominations/choose-how-to-continue", params: form_params
            expect(nomination_email.reload.opened_at).to be_within(2.seconds).of(now)
          end
        end
      end

      context "when opening nomination page for another time" do
        let(:nomination_email) { create :nomination_email, opened_at: 10.days.ago }

        it "does not record opened_at on the nomination_email" do
          expect { post "/nominations/choose-how-to-continue", params: form_params }
            .not_to(change { nomination_email.reload.opened_at })
        end
      end
    end

    context "when the user selects no ECTs this year" do
      let(:form_params) do
        { nominate_how_to_continue_form: { how_to_continue: "no", token: token } }
      end

      it "records the opt out choice" do
        post "/nominations/choose-how-to-continue", params: form_params
        expect(school.school_cohorts.for_year(cohort.start_year).first).to be_opt_out_of_updates
      end
    end

    context "when the user selects that they want to nominate an induction tutor" do
      include_examples "redirects to start nomination", "yes"
    end

    context "when the user selects they want to nominate someone to receive updates" do
      include_examples "redirects to start nomination", "i_dont_know"
    end
  end
end
