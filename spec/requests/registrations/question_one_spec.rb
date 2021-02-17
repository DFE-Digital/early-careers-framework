# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::QuestionOne", type: :request do
  describe "GET /registrations/question-one" do
    it "renders the show template" do
      get "/registrations/question-one"
      expect(response).to render_template("registrations/question_one/show")
    end
  end

  describe "POST /registrations/question-one" do
    it "redirects to /question-two if the answer is 1" do
      post "/registrations/question-one", params: { answer: "1" }
      expect(response).to redirect_to(:registrations_question_two)
    end

    it "redirects to /no-participants if the answer is 2" do
      post "/registrations/question-one", params: { answer: "2" }
      expect(response).to redirect_to(:registrations_no_participants)
    end
  end
end
