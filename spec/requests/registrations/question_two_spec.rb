# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::QuestionTwo", type: :request do
  describe "GET /registrations/question-two" do
    it "renders the show template" do
      get "/registrations/question-two"
      expect(response).to render_template("registrations/question_two/show")
    end
  end

  describe "POST /registrations/question-two" do
    it "redirects to /school-profile if the answer is 1" do
      post "/registrations/question-two", params: { answer: "1" }
      expect(response).to redirect_to(:registrations_school_profile)
    end

    it "redirects to /no-decision if the answer is 2" do
      post "/registrations/question-two", params: { answer: "2" }
      expect(response).to redirect_to(:registrations_no_decision)
    end
  end
end
