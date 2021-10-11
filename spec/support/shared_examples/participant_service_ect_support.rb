# frozen_string_literal: true

RSpec.shared_examples "a participant service for ect" do
  context "when valid user is an early_career_teacher" do
    it "fails when course is for a mentor" do
      params = given_params.merge({ course_identifier: "ecf-mentor" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = given_params.merge({ course_identifier: "npq-leading-teacher" })
      expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
