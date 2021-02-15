# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::QuestionTwo", type: :request do
  describe "GET /registrations/question-two" do
    it "renders the show template" do
      get "/registrations/question-two"
      expect(response).to render_template("registrations/question_two/show")
    end
  end
end
