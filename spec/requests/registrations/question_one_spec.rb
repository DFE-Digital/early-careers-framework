# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::QuestionOne", type: :request do
  describe "GET /registrations/question-one" do
    it "renders the show template" do
      get "/registrations/question-one"
      expect(response).to render_template("registrations/question_one/show")
    end
  end
end
