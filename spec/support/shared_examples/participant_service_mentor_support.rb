# frozen_string_literal: true

RSpec.shared_examples "a participant service for mentor" do
  context "when valid user is an mentor" do
    it "fails when course is for an early career teacher" do
      params = given_params.merge({ course_identifier: "ecf-induction" })
      expect { described_class.new(params: params).call }.to raise_error(ActionController::ParameterMissing)
    end

    it "fails when course is for an npq-course" do
      params = given_params.merge({ course_identifier: "npq-leading-teacher" })
      expect { described_class.new(params: params).call }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
